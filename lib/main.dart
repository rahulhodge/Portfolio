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

// --- Models ---
class Holding {
  final String name;
  final double invested;
  final double current;
  Holding(this.name, this.invested, this.current);
}

class StockHolding {
  final String broker;
  final String name;
  final double invested;
  final double current;
  StockHolding(this.broker, this.name, this.invested, this.current);
}

// --- Home ---
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

  List<Holding> mfHoldings = [];
  List<Holding> etfHoldings = [];
  List<StockHolding> stockHoldings = [];

  void _importData(double sInv, double sCur, double mInv, double mCur, double eInv, double eCur,
      List<Holding> mfList, List<Holding> etfList, List<StockHolding> stockList) {
    setState(() {
      stocksInvested = sInv;
      stocksCurrent = sCur;
      mfInvested = mInv;
      mfCurrent = mCur;
      etfInvested = eInv;
      etfCurrent = eCur;
      mfHoldings = mfList;
      etfHoldings = etfList;
      stockHoldings = stockList;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      OverviewTab(stocksInvested, stocksCurrent, mfInvested, mfCurrent, etfInvested, etfCurrent),
      SwingPolioTab(stocksInvested, stocksCurrent, stockHoldings),
      MfEtfTab(mfInvested, mfCurrent, etfInvested, etfCurrent, mfHoldings, etfHoldings),
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
  final List<StockHolding> stockHoldings;
  const SwingPolioTab(this.invested, this.current, this.stockHoldings, {super.key});

  @override
  Widget build(BuildContext context) {
    final fyers = stockHoldings.where((h) => h.broker == 'Fyers').toList();
    final zerodha = stockHoldings.where((h) => h.broker == 'Zerodha').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(child: ListTile(title: const Text('Stocks Total Invested'), trailing: Text('₹$invested'))),
        Card(child: ListTile(title: const Text('Stocks Current'), trailing: Text('₹$current'))),
        const SizedBox(height: 20),
        const Text('Fyers Holdings', style: TextStyle(fontWeight: FontWeight.bold)),
        ...fyers.map((h) => Card(
          child: ListTile(title: Text(h.name), subtitle: Text('Invested ₹${h.invested}'), trailing: Text('₹${h.current}')),
        )),
        const SizedBox(height: 20),
        const Text('Zerodha Holdings', style: TextStyle(fontWeight: FontWeight.bold)),
        ...zerodha.map((h) => Card(
          child: ListTile(title: Text(h.name), subtitle: Text('Invested ₹${h.invested}'), trailing: Text('₹${h.current}')),
        )),
      ],
    );
  }
}

class MfEtfTab extends StatelessWidget {
  final double mInv, mCur, eInv, eCur;
  final List<Holding> mfHoldings;
  final List<Holding> etfHoldings;
  const MfEtfTab(this.mInv, this.mCur, this.eInv, this.eCur, this.mfHoldings, this.etfHoldings, {super.key});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(child: ListTile(title: const Text('MF Total Invested'), trailing: Text('₹$mInv'))),
      Card(child: ListTile(title: const Text('MF Current'), trailing: Text('₹$mCur'))),
      ...mfHoldings.map((h) => Card(
        child: ListTile(title: Text(h.name), subtitle: Text('Invested ₹${h.invested}'), trailing: Text('₹${h.current}')),
      )),
      const SizedBox(height: 10),
      Card(child: ListTile(title: const Text('ETF Total Invested'), trailing: Text('₹$eInv'))),
      Card(child: ListTile(title: const Text('ETF Current'), trailing: Text('₹$eCur'))),
      ...etfHoldings.map((h) => Card(
        child: ListTile(title: Text(h.name), subtitle: Text('Invested ₹${h.invested}'), trailing: Text('₹${h.current}')),
      )),
    ],
  );
}

// --- Importer ---
class ImporterTab extends StatelessWidget {
  final Function(double,double,double,double,double,double,List<Holding>,List<Holding>,List<StockHolding>) onImport;
  const ImporterTab({super.key, required this.onImport});

  Future<void> _pickFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv','xlsx'],
    );
    if (result != null) {
      final file = File(result.files.single.path!);
      double sInv=0,sCur=0,mInv=0,mCur=0,eInv=0,eCur=0;
      List<Holding> mfList = [];
      List<Holding> etfList = [];
      List<StockHolding> stockList = [];

      if (file.path.endsWith('.csv')) {
        final rows = const CsvToListConverter().convert(await file.readAsString());
        final header = rows.first.map((h) => h.toString().toLowerCase()).toList();

        if (header.contains('name') && header.contains('invested value')) {
          // Fyers format
          for (var row in rows.skip(1)) {
            final name = row[0].toString();
            final invested = double.tryParse(row[3].toString().replaceAll(',','')) ?? 0;
            final current = double.tryParse(row[4].toString().replaceAll(',','')) ?? 0;

            if (name.toLowerCase().contains('fund')) {
              mInv += invested; mCur += current;
              mfList.add(Holding(name, invested, current));
            } else if (name.toLowerCase().contains('etf')) {
              eInv += invested; eCur += current;
              etfList.add(Holding(name, invested, current));
            } else {
              sInv += invested; sCur += current;
              stockList.add(StockHolding('Fyers', name, invested, current));
            }
          }
        } else if (header.contains('instrument') && header.contains('cur. val')) {
          // Zerodha format
          for (var row in rows.skip(1)) {
            final instrument = row[0].toString();
            final invested = double.tryParse(row[4].toString()) ?? 0;
            final current = double.tryParse(row[5].toString()) ?? 0;

            if (instrument.toLowerCase().contains('fund')) {
              mInv += invested; mCur += current;
              mfList.add(Holding(instrument, invested, current));
            } else if (instrument.toLowerCase().contains('bees') || instrument.toLowerCase().contains('etf')) {
              eInv += invested; eCur += current;
              etfList.add(Holding(instrument, invested, current));
            } else {
              sInv += invested; sCur += current;
              stockList.add(StockHolding('Zerodha', instrument, invested, current));
            }
          }
        }
      } else if (file.path.endsWith('.xlsx')) {
        // Excel parsing (generic fallback)
        final bytes = file.readAsBytesSync();
        final excel = Excel.decodeBytes(bytes);
        for (var table in excel.tables.keys) {
          for (var row in excel.tables[table]!.rows.skip(1)) {
            final name = row[0]?.toString() ?? '';
            final invested = double.tryParse(row[1]?.toString() ?? '0') ?? 0;
            final current = double.tryParse(row[2]?.toString() ?? '0') ?? 0;

            if (name.toLowerCase().contains('fund')) {
              mInv += invested; mCur += current;
              mfList.add(Holding(name, invested, current));
            } else if (name.toLowerCase().contains('etf')) {
              eInv += invested; eCur += current;
              etfList.add(Holding(name, invested, current));
            } else {
              sInv += invested; sCur += current;
              stockList.add(StockHolding('Excel', name, invested, current));
            }
          }
        }
      }

      onImport(sInv,sCur,mInv,mCur,eInv,eCur,mfList,etfList,stockList);
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
