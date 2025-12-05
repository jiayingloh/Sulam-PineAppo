import 'package:flutter/material.dart';
import 'homepage.dart';
import 'marketpage.dart';
import 'profilepage.dart';
import 'newannouncementpage.dart';
import 'info.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),   // 0 - Home
    const MarketPage(), // 1 - Market
    Container(),        // 2 - Add (redirect to announcement page)
    const InfoMainPage(),   // 3 - Info
    const ProfilePage() // 4 - Me
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NewAnnouncementPage(),
        ),
      );
      return; // Do not change selectedIndex for Add icon
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 63, 1),
        title: const Text(
          "PineAppo",
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),   // Green-white style (bright green)
            fontSize: 22,                // Slightly larger
            fontWeight: FontWeight.bold, // Bold text
            letterSpacing: 1.2,          // Slight spacing for style
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green[900],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Market"),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Info"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
    );
  }
}
