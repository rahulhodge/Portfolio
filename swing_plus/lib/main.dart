import 'package:flutter/material.dart';

void main() {
  runApp(const SwingPlusApp());
}

class SwingPlusApp extends StatelessWidget {
  const SwingPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swing Plus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF1E1E1E),
        ),
      ),
      home: const TabletDashboardScreen(),
    );
  }
}

class TabletDashboardScreen extends StatefulWidget {
  const TabletDashboardScreen({super.key});

  @override
  State<TabletDashboardScreen> createState() => _TabletDashboardScreenState();
}

class _TabletDashboardScreenState extends State<TabletDashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> dividendHistory = [
    {'stock': 'ITC', 'date': '28 Aug 2026', 'dps': '₹ 7.50', 'qty': '135', 'total': '₹ 1,012.50', 'type': 'Final Dividend'},
    {'stock': 'POWERGRID', 'date': '14 Aug 2026', 'dps': '₹ 4.25', 'qty': '72', 'total': '₹ 306.00', 'type': 'Interim Dividend'},
    {'stock': 'HDFCBANK', 'date': '10 Jul 2026', 'dps': '₹ 19.50', 'qty': '47', 'total': '₹ 916.50', 'type': 'Annual Dividend'},
    {'stock': 'RELIANCE', 'date': '19 Jun 2026', 'dps': '₹ 10.00', 'qty': '11', 'total': '₹ 110.00', 'type': 'Final Dividend'},
    {'stock': 'RADICO', 'date': '02 May 2026', 'dps': '₹ 3.00', 'qty': '16', 'total': '₹ 48.00', 'type': 'Final Dividend'},
  ];

  @override
  Widget build(BuildContext context) {
    final isTabletLandscape = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Left Rail Navigation for Tablet Screen Space
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: isTabletLandscape
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.selected,
            backgroundColor: const Color(0xFF1A1A1A),
            selectedIconTheme: const IconThemeData(color: Color(0xFF00E676)),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard), label: Text('Overview')),
              NavigationRailDestination(icon: Icon(Icons.star), label: Text('Core')),
              NavigationRailDestination(icon: Icon(Icons.local_bar), label: Text('Liquor')),
              NavigationRailDestination(icon: Icon(Icons.show_chart), label: Text('ETFs & Growth')),
              NavigationRailDestination(icon: Icon(Icons.payments), label: Text('Dividends')),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
          
          // Main Body View
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: Text(_getTabTitle(_selectedIndex), style: const TextStyle(fontWeight: FontWeight.bold)),
                elevation: 0,
                backgroundColor: const Color(0xFF121212),
              ),
              body: _buildSelectedScreen(isTabletLandscape),
            ),
          ),
        ],
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0: return 'Swing Plus • Dashboard Overview';
      case 1: return 'Core Bluechip Holdings';
      case 2: return 'Liquor Satellite Portfolio';
      case 3: return 'Index ETFs & High-Growth Plays';
      case 4: return 'Dividends Income Ledger';
      default: return 'Swing Plus';
    }
  }

  Widget _buildSelectedScreen(bool isLandscape) {
    switch (_selectedIndex) {
      case 0: return _buildOverviewTab(isLandscape);
      case 1: return _buildPositionGrid([
          {'name': 'RELIANCE', 'qty': '11', 'buy': '1291.70', 'pnl': '+4.2%'},
          {'name': 'TRENT', 'qty': '8', 'buy': '2727.50', 'pnl': '+8.5%'},
          {'name': 'HDFCBANK', 'qty': '47', 'buy': '810.53', 'pnl': '-1.2%'},
          {'name': 'ITC', 'qty': '135', 'buy': '328.91', 'pnl': '+3.1%'},
          {'name': 'INFY', 'qty': '22', 'buy': '1441.25', 'pnl': '+5.4%'},
        ], isLandscape);
      case 2: return _buildPositionGrid([
          {'name': 'RADICO', 'qty': '16', 'buy': '3967.00', 'pnl': '+12.4%'},
          {'name': 'ABDL', 'qty': '55', 'buy': '669.55', 'pnl': '-2.1%'},
          {'name': 'TI', 'qty': '78', 'buy': '385.26', 'pnl': '+1.8%'},
          {'name': 'UBL', 'qty': '7', 'buy': '1789.32', 'pnl': '-0.5%'},
          {'name': 'UNITEDSPIR', 'qty': '10', 'buy': '1392.18', 'pnl': '+3.8%'},
        ], isLandscape);
      case 3: return _buildPositionGrid([
          {'name': 'ZOMATO', 'qty': '83', 'buy': '250.59', 'pnl': '+28.4%'},
          {'name': 'MO MIDCAP 150', 'qty': '696', 'buy': '60.20', 'pnl': '+6.3%'},
          {'name': 'NIPPON IT ETF', 'qty': '1312', 'buy': '36.89', 'pnl': '-6.6%'},
        ], isLandscape);
      case 4: return _buildDividendTab(isLandscape);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewTab(bool isLandscape) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total Portfolio Value", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 8),
                  Text("₹ 6,52,430", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text("Unrealized P&L: +₹42,310 (+6.9%)", style: TextStyle(color: Color(0xFF00E676), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Bucket Allocation", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: isLandscape ? 3 : 1,
            shrinkWrap: true,
            childAspectRatio: isLandscape ? 2.8 : 4.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildAllocationTile("Core Equity", "₹4,84,000", "74.2%", Colors.blue),
              _buildAllocationTile("Liquor Satellite", "₹1,64,000", "25.2%", Colors.purple),
              _buildAllocationTile("ETFs & Index", "₹1,06,000", "16.2%", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDividendTab(bool isLandscape) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF1E2923),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Dividend Earned", style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(height: 6),
                      Text("₹ 2,393.00", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00E676))),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Yield on Cost", style: TextStyle(color: Colors.grey, fontSize: 15)),
                      SizedBox(height: 6),
                      Text("1.85%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("Payment History (Latest Top)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 2 : 1,
              childAspectRatio: isLandscape ? 3.5 : 4.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dividendHistory.length,
            itemBuilder: (context, index) {
              final item = dividendHistory[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF263238),
                    child: Icon(Icons.account_balance_wallet, color: Color(0xFF00E676)),
                  ),
                  title: Text(item['stock']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text("${item['type']} • ${item['date']}\n${item['qty']} shares @ ${item['dps']}/sh"),
                  isThreeLine: true,
                  trailing: Text(
                    item['total']!,
                    style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationTile(String title, String val, String pct, Color color) {
    return Card(
      child: Center(
        child: ListTile(
          leading: CircleAvatar(backgroundColor: color, radius: 10),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(val),
          trailing: Text(pct, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  Widget _buildPositionGrid(List<Map<String, String>> items, bool isLandscape) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLandscape ? 2 : 1,
        childAspectRatio: isLandscape ? 3.8 : 4.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isPositive = item['pnl']!.startsWith('+');
        return Card(
          child: Center(
            child: ListTile(
              title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text("Qty: ${item['qty']} | Avg: ₹${item['buy']}"),
              trailing: Text(
                item['pnl']!,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF00E676) : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}