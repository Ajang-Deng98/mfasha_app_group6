import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'AdminHealthcareScreen.dart';
import 'emergency_hotlines.dart';
import 'emergency_guides/emergency_guides_screen.dart';

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

    switch (index) {
      case 0:
        if (_selectedIndex != 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
        break;
      case 1:
      // Navigate to Hospital screen
        break;
      case 2:
      // Navigate to Emergency Guides screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyGuidesScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage()),
        );
        break;
      case 4:
      // Navigate to Emergency Hotlines
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => EmergencyHotlinesScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F5F8),
        elevation: 0,
        automaticallyImplyLeading: false,
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
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              height: 80,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyGuidesScreen()),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Hot Lines'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyHotlinesScreen()),
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Crisis Alerts'),
              onTap: () {
                // Navigate to crisis alerts screen
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ) : null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health Hub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your go-to source for health information',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Quick Access Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAccessButton(
                    icon: Icons.local_hospital,
                    label: 'Health Facilities',
                    onTap: () => _onItemTapped(1),
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.medical_services,
                    label: 'Emergency Guides',
                    onTap: () => _onItemTapped(2),
                  ),
                  _buildQuickAccessButton(
                    icon: Icons.phone,
                    label: 'Emergency Contacts',
                    onTap: () => _onItemTapped(4),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recommended Health Facilities Section
              const Text(
                'Recommended Health Facilities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Features Row
              Row(
                children: [
                  _buildFeatureChip('Open 24/7'),
                  const SizedBox(width: 8),
                  _buildFeatureChip('Specialized care'),
                ],
              ),
              const SizedBox(height: 16),

              // Facilities List
              Column(
                children: [
                  _buildHealthFacilityCard(
                    icon: Icons.local_hospital,
                    name: 'City Hospital',
                    rating: 5.0,
                  ),
                  const SizedBox(height: 16),
                  _buildHealthFacilityCard(
                    icon: Icons.medical_services,
                    name: 'Wellness Clinic',
                    rating: 4.5,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital, size: 24),
            label: 'Hospital',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_active, size: 24),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone, size: 24),
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

  Widget _buildQuickAccessButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 32, color: Colors.blue),
          onPressed: onTap,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String text) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  Widget _buildHealthFacilityCard({required IconData icon, required String name, required double rating}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(
                        '$rating-star rating',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}