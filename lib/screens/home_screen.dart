import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Hub")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Recommended Health Facilities",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text("City Hospital"),
              subtitle: const Text("5-star rating"),
              leading: const Icon(Icons.local_hospital),
            ),
            ListTile(
              title: const Text("Wellness Clinic"),
              subtitle: const Text("4.5-star rating"),
              leading: const Icon(Icons.local_hospital),
            ),
            const SizedBox(height: 20),
            const Text(
              "Emergency Contacts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text("The Brigade"),
              subtitle: const Text("Dial 119"),
              leading: const Icon(Icons.call),
            ),
          ],
        ),
      ),
    );
  }
}
