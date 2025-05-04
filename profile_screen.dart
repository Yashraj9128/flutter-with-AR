import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndLoadProfile();
  }

  Future<void> _checkAuthenticationAndLoadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
    } else {
      setState(() {
        _userEmail = user.email;
        _emailController.text = user.email ?? '';
      });
      await _loadProfile();
    }
  }

  Future<void> _loadProfile() async {
    if (_userEmail == null) return;

    final prefs = await SharedPreferences.getInstance();
    _nameController.text = prefs.getString('${_userEmail}_name') ?? '';
    _phoneController.text = prefs.getString('${_userEmail}_phone') ?? '';
    final imagePath = prefs.getString('${_userEmail}_image');

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      if (_userEmail != null) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('${_userEmail}_image', pickedFile.path);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill in all profile details")),
      );
      return;
    }

    if (_userEmail == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_userEmail}_name', _nameController.text.trim());
    await prefs.setString('${_userEmail}_phone', _phoneController.text.trim());
    await prefs.setString('${_userEmail}_email', _emailController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Profile saved successfully")),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            // Save Profile Button
            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text(
                    'Save Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // View Cart Button
            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text(
                    'View Cart',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Logout Button
            Center(
              child: SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
