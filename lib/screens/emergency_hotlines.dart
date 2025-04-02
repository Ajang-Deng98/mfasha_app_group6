import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHotlinesScreen extends StatelessWidget {
  final CollectionReference hotlines =
      FirebaseFirestore.instance.collection('hotlines');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Space from top
            Center(
              child: Text(
                'Emergency Hotlines',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Click on the emergency service to find contact & location",
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: hotlines.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No hotlines available"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final String name = doc['name'] ?? 'Unknown';
                      final String contact = doc['contact'].toString(); // Fixed field name
                      return HotlineTile(
                        name: name,
                        contact: contact,
                        icon: _getEmergencyIcon(name),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Highlight the contacts tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // navigate to home
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 1:
              // navigate to search
              break;
            case 2:
              // navigate to alerts
              break;
            case 3:
              // navigate to profile
              break;
            case 4:
              // navigate to contacts
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmergencyHotlinesScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  // Function to assign different icons based on the service name
  IconData _getEmergencyIcon(String name) {
    if (name.toLowerCase().contains("ambulance")) return Icons.local_hospital;
    if (name.toLowerCase().contains("police")) return Icons.local_police;
    if (name.toLowerCase().contains("fire")) return Icons.local_fire_department;
    if (name.toLowerCase().contains("child")) return Icons.child_care;
    if (name.toLowerCase().contains("violence")) return Icons.family_restroom;
    return Icons.phone; // Default icon
  }
}

class HotlineTile extends StatelessWidget {
  final String name;
  final String contact;
  final IconData icon;

  HotlineTile({required this.name, required this.contact, required this.icon});

  void _callNumber(String contact) async {
    final Uri url = Uri.parse('tel:$contact');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $contact';
    }
  }

  void _openLocation() {
    // Placeholder for location functionality
    print("Open location for $name");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.redAccent),
        title: Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(contact, style: TextStyle(color: Colors.grey[700])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.location_on, color: Colors.blue),
              onPressed: _openLocation,
            ),
            IconButton(
              icon: Icon(Icons.call, color: Colors.green),
              onPressed: () => _callNumber(contact),
            ),
          ],
        ),
      ),
    );
  }
}