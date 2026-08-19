import 'package:flutter/material.dart';

void main() {
  runApp(const SmartMeterApp());
}

class SmartMeterApp extends StatelessWidget {
  const SmartMeterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Utility Meter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
      home: const MainHomeScreen(),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  // 15th Feature: Top Line Meter Selector
  String selectedMeter = 'All Meters';
  int _currentIndex = 0;

  // Sample Budget Data
  double totalBudget = 30000.0;
  double currentBill = 17600.0;

  final List<String> meterList = [
    'All Meters',
    'Meter 1 (Ground Floor)',
    'Meter 2 (Upper Floor)',
    'Meter 3 (Motor/Heavy)',
    'Gas Meter',
  ];

  @override
  Widget build(BuildContext context) {
    double remainingBalance = totalBudget - currentBill;

    return Scaffold(
      // TOP BAR WITH HAMBURGER MENU & TOP LINE METER DROP-DOWN
      appBar: AppBar(
        backgroundColor: Colors.teal.shade800,
        elevation: 2,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedMeter,
            dropdownColor: Colors.teal.shade900,
            icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.amber),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            onChanged: (String? newValue) {
              setState(() {
                selectedMeter = newValue!;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فلٹر تبدیل کر دیا گیا: $selectedMeter')),
              );
            },
            items: meterList.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.amber),
            onPressed: () {},
          )
        ],
      ),

      // SIDE DRAWER MENU (TOP MENU - 7 OPTIONS)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.teal.shade800),
              accountName: const Text("Smart Meter Control", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text("Selected: $selectedMeter", style: const TextStyle(color: Colors.amber)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.electric_meter, color: Colors.teal, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.teal),
              title: const Text('01. Export & Reports (ڈیٹا ڈاؤن لوڈ)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.record_voice_over, color: Colors.teal),
              title: const Text('02. Voice & Sound Alerts (وائس سیٹنگ)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.edit_note, color: Colors.teal),
              title: const Text('03. Meter Names Management (نام تبدیل کریں)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.event_available, color: Colors.teal),
              title: const Text('04. Bill Expire & Due Dates (تاریخیں)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.teal),
              title: const Text('05. Main Settings & Tariff (ریٹ و سلیب)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.teal),
              title: const Text('06. Limit & Budget Control (حدود)'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.cloud_sync, color: Colors.teal),
              title: const Text('07. Backup & Restore (ڈیٹا محفوظ کریں)'),
              onTap: () {},
            ),
          ],
        ),
      ),

      // MAIN BODY BASED ON SELECTED BOTTOM TAB
      body: _buildScreenContent(remainingBalance),

      // FLOATING ACTION BUTTON (QUICK READING)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQuickReadingDialog();
        },
        backgroundColor: Colors.amber.shade700,
        icon: const Icon(Icons.add_a_photo, color: Colors.black),
        label: const Text("➕ Quick Reading", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),

      // BOTTOM NAVIGATION BAR (5 BUTTONS)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal.shade800,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.electric_bolt), label: 'Electricity'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Gas Meter'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
      ),
    );
  }

  // BUILD CONTENT SWITCHER
  Widget _buildScreenContent(double remainingBalance) {
    if (_currentIndex == 0) {
      return _buildDashboard(remainingBalance);
    }
    return Center(
      child: Text(
        "Screen: ${_getTabTitle(_currentIndex)}\n(Filter Active: $selectedMeter)",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 1: return "Electricity Meters Detail";
      case 2: return "Gas Meter Detail";
      case 3: return "Analytics & Monthly History";
      case 4: return "Active Alerts & Voice Reminders";
      default: return "Dashboard";
    }
  }

  // DASHBOARD DESIGN
  Widget _buildDashboard(double remainingBalance) {
    bool isWithinBudget = remainingBalance >= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SMART RECOMMENDATION BANNER
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade800),
            ),
            child: Row(
              children: const [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "سمارٹ تجویز: میٹر 1 کے 280 یونٹس ہو چکے ہیں۔ بوجھ دوسرے میٹر پر شفٹ کریں!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // TOP BALANCE OVERVIEW CARD
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Budget: PKR ${totalBudget.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey)),
                      Text("Est. Bill: PKR ${currentBill.toStringAsFixed(0)}", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text("REMAINING BALANCE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    "PKR ${remainingBalance.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isWithinBudget ? Colors.green.shade700 : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Meter Status ($selectedMeter)",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black80),
          ),
          const SizedBox(height: 10),

          // METER CARDS LIST
          if (selectedMeter == 'All Meters' || selectedMeter.contains('Meter 1'))
            _buildMeterCard("Meter 1 (Ground)", "280 / 300 Units", "PKR 8,200", Colors.orange, true),
          if (selectedMeter == 'All Meters' || selectedMeter.contains('Meter 2'))
            _buildMeterCard("Meter 2 (Upper)", "140 / 300 Units", "PKR 4,100", Colors.green, false),
          if (selectedMeter == 'All Meters' || selectedMeter.contains('Meter 3'))
            _buildMeterCard("Meter 3 (Motor)", "190 / 300 Units", "PKR 5,300", Colors.green, false),
          if (selectedMeter == 'All Meters' || selectedMeter.contains('Gas'))
            _buildMeterCard("Gas Meter", "1.2 Hm3 (Slab 1)", "PKR 1,200", Colors.green, false),
        ],
      ),
    );
  }

  // METER CARD WIDGET
  Widget _buildMeterCard(String title, String units, String bill, Color statusColor, bool hasWarning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.speed, color: statusColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Slab Status: $units"),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAlignment.end,
          children: [
            Text(bill, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
            if (hasWarning)
              const Text("⚠️ Limit Near", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // QUICK READING DIALOG
  void _showQuickReadingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Quick Reading Entry ($selectedMeter)"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter Reading Value",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text("Capture Meter Image"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ریڈنگ کامیابی سے محفوظ کر لی گئی ہے!')),
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
