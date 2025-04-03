import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'guide_detail_screen.dart';
import 'models/guide_model.dart';

class EmergencyGuidesScreen extends StatefulWidget {
  @override
  _EmergencyGuidesScreenState createState() => _EmergencyGuidesScreenState();
}

class _EmergencyGuidesScreenState extends State<EmergencyGuidesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 2; // Set to 2 since this is the Emergency screen

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Handle navigation to different screens based on index
    switch (index) {
      case 0: // Home
        Navigator.pushNamed(context, '/home');
        break;
      case 1: // Hospital
        Navigator.pushNamed(context, '/hospitals');
        break;
      case 2: // Emergency (current screen)
      // Do nothing as we're already here
        break;
      case 3: // Chat
        Navigator.pushNamed(context, '/chat');
        break;
      case 4: // Call
        Navigator.pushNamed(context, '/emergency-call');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Guides'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('emergencyGuides').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading guides'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No guides available'));
                  }

                  // Create additional guide entries
                  final additionalGuides = [
                    EmergencyGuide(
                      id: 'earthquake_safety',
                      category: 'Earthquake Safety',
                      textContent1: 'Earthquake safety instructions...',
                      textContent2: '',
                      textContent3: '',
                    ),
                    EmergencyGuide(
                      id: 'flood_preparedness',
                      category: 'Flood Preparedness',
                      textContent1: 'Flood preparedness guidelines...',
                      textContent2: '',
                      textContent3: '',
                    ),
                  ];

                  final guides = [
                    ...snapshot.data!.docs.map((doc) => EmergencyGuide.fromFirestore(doc)),
                    ...additionalGuides,
                  ];

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: guides.length,
                    itemBuilder: (context, index) {
                      final guide = guides[index];
                      return _GuideCard(guide: guide);
                    },
                  );
                },
              ),
            ),
          ],
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
}

class _GuideCard extends StatelessWidget {
  final EmergencyGuide guide;

  const _GuideCard({required this.guide, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideDetailScreen(guide: guide),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              guide.category,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}