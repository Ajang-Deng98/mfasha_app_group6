import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHealthcareForm extends StatefulWidget {
  @override
  _AdminHealthcareFormState createState() => _AdminHealthcareFormState();
}

class _AdminHealthcareFormState extends State<AdminHealthcareForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  List<String> _services = ['', '', ''];
  List<String> _specialties = ['', '', ''];
  bool _isAdmin = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data()?['type'] == 'admin') {
        setState(() {
          _isAdmin = true;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _addService() {
    setState(() {
      _services.add('');
    });
  }

  void _addSpecialty() {
    setState(() {
      _specialties.add('');
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _isAdmin) {
        final docRef = FirebaseFirestore.instance.collection('healthCareProviders').doc();
        await docRef.set({
          'name': _nameController.text,
          'address': _addressController.text,
          'contact': int.tryParse(_contactController.text) ?? 0,
          'hours': _hoursController.text,
          'services': _services.where((s) => s.isNotEmpty).toList(),
          'specialties': _specialties.where((s) => s.isNotEmpty).toList(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Healthcare Provider Added Successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isAdmin) {
      return Scaffold(
        body: Center(child: Text('Access Denied')), // Deny access if not admin
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Admin - Add Healthcare Provider')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter an address' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter a contact number' : null,
              ),
              TextFormField(
                controller: _hoursController,
                decoration: InputDecoration(labelText: 'Operating Hours'),
                validator: (value) => value!.isEmpty ? 'Enter operating hours' : null,
              ),
              SizedBox(height: 10),
              Text('Services:'),
              ..._services.asMap().entries.map((entry) {
                int idx = entry.key;
                return TextFormField(
                  initialValue: entry.value,
                  decoration: InputDecoration(labelText: 'Service ${idx + 1}'),
                  onChanged: (val) => _services[idx] = val,
                );
              }).toList(),
              TextButton(onPressed: _addService, child: Text('Add Service')),
              SizedBox(height: 10),
              Text('Specialties:'),
              ..._specialties.asMap().entries.map((entry) {
                int idx = entry.key;
                return TextFormField(
                  initialValue: entry.value,
                  decoration: InputDecoration(labelText: 'Specialty ${idx + 1}'),
                  onChanged: (val) => _specialties[idx] = val,
                );
              }).toList(),
              TextButton(onPressed: _addSpecialty, child: Text('Add Specialty')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submitForm, child: Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}
