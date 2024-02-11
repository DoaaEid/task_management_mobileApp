import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Viwes/Admin/list_employee_view.dart';
import 'package:task_management/Viwes/Admin/list_task_view.dart';
import 'package:task_management/Viwes/Authentication/login_view.dart';
import 'package:task_management/Viwes/Tasks/task_manager_service_view.dart';

class HomePageAdmin extends StatefulWidget {
  const HomePageAdmin({Key? key}) : super(key: key);

  @override
  _HomePageAdminState createState() => _HomePageAdminState();
}

class _HomePageAdminState extends State<HomePageAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 1,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 10.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.indigo[400],
                  title: Text("حساب مدير"),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout),
                      onPressed: _handleLogout,
                    ),
                  ],
                ),
              ];
            },
            body: ListTask(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(AntDesign.home),
            label: 'الصفحة الرئيسيية',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.addfile),
            label: 'اضافة مهمة',
          ),
          BottomNavigationBarItem(
            icon: Icon(AntDesign.adduser),
            label: 'اضافة موظف',
          ),
        ],
        selectedItemColor: Colors.white,
        backgroundColor: Colors.indigo[400],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListTask(),
              ),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeTaskPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ListEmployee(),
              ),
            );
          }
        },
      ),
    );
  }

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    await SharedPreferencesUtil.clearUserDataFromPrefs();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}

class SharedPreferencesUtil {
  static Future<void> clearUserDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_id');
  }
}
