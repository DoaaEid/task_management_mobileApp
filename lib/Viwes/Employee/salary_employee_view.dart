import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Salary extends StatefulWidget {
  const Salary({Key? key}) : super(key: key);

  @override
  _SalaryState createState() => _SalaryState();
}

class _SalaryState extends State<Salary> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? userId;
  bool isWorking = false;
  DateTime? startTime;
  double dailySalary = 0.0;
  double monthlySalary = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _checkWorkInProgress();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  Future<void> _checkWorkInProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isWorkingInProgress = prefs.getBool('isWorkingInProgress') ?? false;
    if (isWorkingInProgress) {
      setState(() {
        isWorking = true;
        startTime = DateTime.parse(prefs.getString('startTime')!);
        dailySalary = prefs.getDouble('dailySalary') ?? 0.0;
      });

      timer = Timer.periodic(Duration(minutes: 1), (timer) {
        _updateUI();
      });
    }

    int currentMonth = DateTime.now().month;
    int storedMonth = prefs.getInt('storedMonth') ?? 0;
    if (currentMonth != storedMonth) {
      prefs.setInt('storedMonth', currentMonth);
      monthlySalary = 0.0;
      prefs.setDouble('monthlySalary', monthlySalary);
    } else {
      monthlySalary = prefs.getDouble('monthlySalary') ?? 0.0;
    }
  }

  Future<void> _startWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isWorking = true;
      startTime = DateTime.now();
    });

    prefs.setBool('isWorkingInProgress', true);
    prefs.setString('startTime', startTime!.toIso8601String());
    prefs.remove('endTime');
    prefs.remove('dailySalary');
  }

  Future<void> _finishWork() async {
    if (startTime != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DateTime endTime = DateTime.now();
      Duration workDuration = endTime.difference(startTime!);

      double hourlyRate = 15.5;
      dailySalary = (workDuration.inMinutes / 60) * hourlyRate;

      await _firestore.collection('salary').doc(userId).collection('daily_salaries').add({
        'start_time': startTime,
        'end_time': endTime,
        'daily_salary': dailySalary,
      });

      monthlySalary += dailySalary;

      prefs.setBool('isWorkingInProgress', false);
      prefs.remove('startTime');
      prefs.setString('endTime', endTime.toIso8601String());
      prefs.setDouble('dailySalary', dailySalary);

      prefs.setDouble('monthlySalary', monthlySalary);

      setState(() {
        isWorking = false;
        startTime = null;
      });
    }
  }

  void _updateUI() {
    if (startTime != null) {
      setState(() {
        dailySalary = (DateTime.now().difference(startTime!).inMinutes / 60) * 15.5;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("حساب الراتب"),
        backgroundColor: Colors.indigo[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isWorking)
              Text(
                ' !انت تعمل الان',
                style: TextStyle(fontSize: 20),
              )
            else
              Text(
                '!انت لم تعمل حتى الان',
                style: TextStyle(fontSize: 20),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isWorking ? _finishWork : _startWork,
              child: Container(
                width: 200, // Set the desired width
                height: 50, // Set the desired height
                alignment: Alignment.center,
                child: Text(
                  isWorking ? 'انتهاء العمل' : 'بدأ العمل',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo[300],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'الراتب اليومي: \$${dailySalary.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'راتب الشهر: \$${monthlySalary.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
