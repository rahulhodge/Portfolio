import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

void main() => runApp(const PortfolioApp());

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Portfolio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PortfolioHome(),
    );
  }
}

class PortfolioHome extends StatefulWidget {
  const PortfolioHome({super.key});
  @override
  State<PortfolioHome> createState() => _PortfolioHomeState();
}

class _PortfolioHomeState extends State<PortfolioHome> {
  int _selectedIndex = 0;

  double stocksInvested = 0, stocksCurrent = 0;
  double mfInvested = 0, mfCurrent = 0;
  double etfInvested = 0, etfCurrent = 0;

  void _importData(double sInv, double sCur, double mInv, double mCur, double eInv, double eCur) {
    setState(() {
      stocksInvested = sInv;
      stocksCurrent = sCur;
      mfInvested = mInv;
      mfCurrent = mCur;
      etfInvested = eInv;
      etfCurrent = eCur;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewTab(stocksInvested, stocksCurrent, mfInvested, mfCurrent, etfInvested, etfCurrent),
      SwingPolioTab(stocksInvested, stocksCurrent),
      MfEtfTab(mfInvested, mfCurrent, etfInvested, etfCurrent),
      ImporterTab(onImport: _importData),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'SwingPolio'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'MF/ETF'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Importer'),
        ],
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// --- Tabs ---
class OverviewTab extends StatelessWidget {
  final double sInv, sCur, mInv, mCur, eInv, eCur;
  const OverviewTab(this.sInv, this.sCur, this.mInv, this.mCur, this.eInv, this.eCur, {super.key});

  @override
  Widget build(BuildContext context) {
    final totalInv = sInv + mInv + eInv;
    final totalCur = sCur + mCur + eCur;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: ListTile(title: const Text('Total Invested'), trailing: Text('₹$totalInv'))),
        Card(child: ListTile(title: const Text('Current Value'), trailing: Text('₹$totalCur'))),
        const SizedBox(height: 20),
        Card(
          child: Column(children: [
            ListTile(title: const Text('Stocks'), trailing: Text('₹$sCur')),
            ListTile(title: const Text('MF'), trailing: Text('₹$mCur')),
            ListTile(title: const Text('ETF'), trailing: Text('₹$eCur')),
          ]),
        ),
      ],
    );
  }
}

class SwingPolioTab extends StatelessWidget {
  final double invested, current;
  const SwingPolioTab(this.invested, this.current, {super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(child: ListTile(title: const Text('Stocks Invested'), trailing: Text('₹$invested'))),
      Card(child: ListTile(title: const Text('Stocks Current'), trailing: Text('₹$current'))),
    ],
  );
}

class MfEtfTab extends StatelessWidget {
  final double mInv, mCur, eInv, eCur;
  const MfEtfTab(this.mInv, this.mCur, this.eInv, this.eCur, {super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(child: ListTile(title: const Text('MF Invested'), trailing: Text('₹$mInv'))),
      Card(child: ListTile(title: const Text('MF Current'), trailing: Text('₹$mCur'))),
      const SizedBox(height: 10),
      Card(child: ListTile(title: const Text('ETF Invested'), trailing: Text('₹$eInv'))),
      Card(child: ListTile(title: const Text('ETF Current'), trailing: Text('₹$eCur'))),
    ],
  );
}

class ImporterTab extends StatelessWidget {
  final Function(double,double,double,double,double,double) onImport;
  const ImporterTab({super.key, required this.onImport});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv','xlsx'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      double sInv=0,sCur=0,mInv=0,mCur=0,eInv=0,eCur=0;
      if (file.path.endsWith('.csv')) {
        final rows = const CsvToListConverter().convert(await file.readAsString());
        for (var row in rows.skip(1)) {
          if (row[0]=='stock'){ sInv+=row[1]; sCur+=row[2]; }
          if (row[0]=='mf'){ mInv+=row[1]; mCur+=row[2]; }
          if (row[0]=='etf'){ eInv+=row[1]; eCur+=row[2]; }
        }
      } else if (file.path.endsWith('.xlsx')) {
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);
        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows.skip(1)) {
            final type = row[0]?.toString().toLowerCase();
            final inv = double.tryParse(row[1]?.toString() ?? '0') ?? 0;
            final cur = double.tryParse(row[2]?.toString() ?? '0') ?? 0;
            if (type=='stock'){ sInv+=inv; sCur+=cur; }
            if (type=='mf'){ mInv+=inv; mCur+=cur; }
            if (type=='etf'){ eInv+=inv; eCur+=cur; }
          }
        }
      }
      onImport(sInv,sCur,mInv,mCur,eInv,eCur);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Imported ${file.path}")));
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: ElevatedButton.icon(
      icon: const Icon(Icons.upload_file),
      label: const Text("Upload Broker File"),
      onPressed: () => _pickFile(context),
    ),
  );
}
