import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHotlinesScreen extends StatelessWidget {
  final CollectionReference hotlines =
      FirebaseFirestore.instance.collection('hotlines');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Hotlines'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Click on the emergency care you want and you find the location and contact",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
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
                      final String contact = doc['contact'].toString();
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
        currentIndex: 4,
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
              Navigator.popUntil(context, (route) => route.isFirst);
              break;
            case 4:
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

  IconData _getEmergencyIcon(String name) {
    if (name.toLowerCase().contains("ambulance")) return Icons.local_hospital;
    if (name.toLowerCase().contains("police")) return Icons.local_police;
    if (name.toLowerCase().contains("fire")) return Icons.local_fire_department;
    if (name.toLowerCase().contains("child")) return Icons.child_care;
    if (name.toLowerCase().contains("violence")) return Icons.family_restroom;
    return Icons.phone;
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
    print("Open location for $name");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.redAccent),
        ),
        title: Text(
          name,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          contact,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
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