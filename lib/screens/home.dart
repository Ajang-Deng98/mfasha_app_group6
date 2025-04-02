import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Remove Iconify and use Flutter's built-in icons instead
import 'chat_page.dart';
import 'AdminHealthcareScreen.dart';
import 'emergency_hotlines.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _isAdmin = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  // Check if current user is an admin
  Future<void> _checkAdminStatus() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _isAdmin = userData['type'] == 'admin';
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigation based on the selected index
    switch (index) {
      case 0:
      // Navigate to Home screen - avoid recreation of the same screen
        if (_selectedIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
        break;
      case 1:
      // Navigate to Hospital screen
      // Replace with your hospital screen navigation
        break;
      case 2:
      // Navigate to Siren screen
      // Replace with your siren/emergency screen navigation
        break;
      case 3:
      // Navigate to Chat/Book screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage()),
        );
        break;
      case 4:
      //navigate to contacts
      // You can implement a phone call feature or navigate to a call screen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'MFASHA',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: _isAdmin ? IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ) : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black),
            onPressed: () {
              // Handle profile action
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () {
              // Handle notifications action
            },
          ),
        ],
      ),
      drawer: _isAdmin ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 80, // Reduced drawer header height
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              title: const Text('Healthcare Facilities'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HealthCareFacilitiesScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Emergency Guides'),
              onTap: () {
                // Navigate to emergency guides screen
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ) : null,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20)
          ),
          const Center(
            child: Text(
              'Welcome to Mfasha Health App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Ask AI",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: _selectedIndex == 0 ? Colors.blue : Colors.black,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.local_hospital,
              color: _selectedIndex == 1 ? Colors.blue : Colors.black,
              size: 24,
            ),
            label: 'Hospital',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_active,  // Using notification icon for emergency
              color: _selectedIndex == 2 ? Colors.blue : Colors.black,
              size: 24,
            ),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,  // Using chat icon instead of book
              color: _selectedIndex == 3 ? Colors.blue : Colors.black,
              size: 24,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.phone,
              color: _selectedIndex == 4 ? Colors.blue : Colors.black,
              size: 24,
            ),
            label: 'Call',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }
}