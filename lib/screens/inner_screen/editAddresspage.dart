import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shopsmart_users_en/screens/profile_screen.dart';

class EditAddressPage extends StatefulWidget {
  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late TextEditingController _addressController;
  late String _userId;
  late String _userAddress;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    // Fetch user ID
    _userId = FirebaseAuth.instance.currentUser!.uid;
    // Fetch user address from Firestore
    _fetchUserAddress();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserAddress() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get();
      setState(() {
        _userAddress = userSnapshot.get('userAddress');
        _addressController.text = _userAddress;
      });
    } catch (error) {
      print('Error fetching user address: $error');
    }
  }

  Future<void> _updateUserAddress() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .update({'userAddress': _addressController.text});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User address updated successfully'),
        ),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    } catch (error) {
      print('Error updating user address: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating user address: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User Address'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Address:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter user address',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserAddress,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
