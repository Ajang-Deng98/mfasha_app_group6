import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AddHealthcareProviders.dart';

class HealthCareFacilitiesScreen extends StatefulWidget {
  @override
  _HealthCareFacilitiesScreenState createState() => _HealthCareFacilitiesScreenState();
}

class _HealthCareFacilitiesScreenState extends State<HealthCareFacilitiesScreen> {
  final CollectionReference healthcareProviders =
  FirebaseFirestore.instance.collection('healthCareProviders');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdminStatus();
  }

  void checkAdminStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        isAdmin = userDoc.exists && userDoc['type'] == 'admin';
      });
    }
  }

  Map<String, bool> expanded = {};
  Map<String, Map<String, dynamic>> editedData = {};

  void toggleExpand(String id) {
    setState(() {
      expanded[id] = !(expanded[id] ?? false);
    });
  }

  void navigateToAddProvider() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminHealthcareForm()),
    );
  }

  void deleteProvider(String id) async {
    await healthcareProviders.doc(id).delete();
  }

  void updateProvider(String id) async {
    await healthcareProviders.doc(id).update(editedData[id] ?? {});
    setState(() {
      editedData.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("HealthCare Facilities", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (isAdmin)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: navigateToAddProvider,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF080540),
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: healthcareProviders.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text("No facilities available"));
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String id = doc.id;
                      bool isEditing = editedData.containsKey(id);
                      return Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black.withOpacity(0.24)),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['name'] ?? '',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAdmin)
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      setState(() {
                                        editedData[id] = Map.from(data);
                                      });
                                    },
                                  ),
                                IconButton(
                                  icon: Icon(expanded[id] == true ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                                  onPressed: () => toggleExpand(id),
                                )
                              ],
                            ),
                            if (expanded[id] == true)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var field in ['address', 'contact', 'hours'])
                                    isEditing
                                        ? TextField(
                                      onChanged: (value) => editedData[id]![field] = value,
                                      controller: TextEditingController(text: data[field]?.toString() ?? ''),
                                      decoration: InputDecoration(labelText: field.capitalize()),
                                    )
                                        : Text("${field.capitalize()}: ${data[field]}", style: TextStyle(fontSize: 16)),
                                  for (var field in ['services', 'specialties'])
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("${field.capitalize()}:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                        ...List.generate((data[field] as List?)?.length ?? 0, (index) {
                                          return isEditing
                                              ? TextField(
                                            onChanged: (value) => editedData[id]![field][index] = value,
                                            controller: TextEditingController(text: data[field][index]),
                                            decoration: InputDecoration(labelText: "${field.capitalize()} ${index + 1}"),
                                          )
                                              : Text("- ${data[field][index]}", style: TextStyle(fontSize: 16));
                                        }),
                                        if (isEditing)
                                          IconButton(
                                            icon: Icon(Icons.add_circle, color: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                editedData[id]![field] = [...?editedData[id]![field], ""];
                                              });
                                            },
                                          ),
                                      ],
                                    ),
                                  if (isEditing)
                                    ElevatedButton(
                                      onPressed: () => updateProvider(id),
                                      child: Text("Update"),
                                    ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => deleteProvider(id),
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}