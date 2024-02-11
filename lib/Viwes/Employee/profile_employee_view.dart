import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEmployeePage extends StatefulWidget {
  @override
  _ProfileEmployeePageState createState() => _ProfileEmployeePageState();
}

class _ProfileEmployeePageState extends State<ProfileEmployeePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  Map<String, dynamic>? _userData;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _mobileController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    _user = _auth.currentUser!;
    await _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get();

      Map<String, dynamic> userData =
      userSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _userData = userData;
        _firstNameController =
            TextEditingController(text: _userData!['firstName']);
        _lastNameController =
            TextEditingController(text: _userData!['lastName']);
        _mobileController =
            TextEditingController(text: _userData!['mobile']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .update({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'mobile': _mobileController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الشخصية'),
        backgroundColor: Colors.indigo[300],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/wc.png',
                  height: 120,
                  width: 120,
                ),
                SizedBox(height: 20),
                buildReadOnlyTextField(
                  'البريد الاكتروني (قراءة)',
                  _userData!['email'],
                ),
                SizedBox(height: 20),
                buildEditableTextField(
                  'الاسم الاول',
                  _firstNameController,
                ),
                SizedBox(height: 20),
                buildEditableTextField(
                  'الاسم الاخير',
                  _lastNameController,
                ),
                SizedBox(height: 20),
                buildEditableTextField(
                  'رقم الهاتف',
                  _mobileController,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.indigo[300],
                        elevation: 8,
                      ),
                      child: Text(
                        'Update User Data',
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableTextField(
      String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontFamily: 'Pacifico',
          fontSize: 18.0,
          color: Colors.blueGrey,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 16.0,
            color: Colors.blueGrey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget buildReadOnlyTextField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 16.0,
            color: Colors.blueGrey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.all(12),
        ),
        controller: TextEditingController(text: value),
        readOnly: true,
      ),
    );
  }
}
