// userDetailsPage.dart
import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  final String firstName;
  final String email;
  final String lastName;
  final String mobile;


  UserDetailsPage({
    required this.firstName,
    required this.email,
    required this.lastName,
    required this.mobile,

  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الموظف'),
        backgroundColor: Colors.indigo[300],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              enabled: false,
              initialValue: 'الاسم الاول: $firstName',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              enabled: false,
              initialValue: 'الاسم االاخير: $lastName',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              enabled: false,
              initialValue: 'البريد الاكتروني: $email',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              enabled: false,
              initialValue: 'رقم الهاتف: $mobile',
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
