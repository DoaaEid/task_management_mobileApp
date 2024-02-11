import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_management/Viwes/Employee/task_details_employee_view.dart';

class MyTaskPage extends StatefulWidget {
  @override
  _MyTaskPageState createState() => _MyTaskPageState();
}

class _MyTaskPageState extends State<MyTaskPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Task Page'),
        backgroundColor: Colors.indigo[300],
      ),
      body: FutureBuilder(
        future: _getTasksForCurrentUser(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData && (snapshot.data?.isEmpty ?? true)) {
            return Center(child: Text('No tasks available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final taskData = snapshot.data![index];

                return TaskContainer(
                  documentId: taskData['documentId'],
                  taskTitle: taskData['task_title'],
                  description: taskData['description'],
                  job_type: taskData['job_type'],
                  start_date: taskData['start_date'],
                  end_date: taskData['end_date'],
                  subtasks: taskData['subtasks'] != null ? List.from(taskData['subtasks']) : [],
                  firestore: _firestore,
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getTasksForCurrentUser() async {
    final User? currentUser = _auth.currentUser;
    final String userFirstName = currentUser != null
        ? (await _firestore.collection('users').doc(currentUser.uid).get())['firstName']
        : '';

    final QuerySnapshot tasksSnapshot = await _firestore.collection('tasks').where('firstName', isEqualTo: userFirstName).get();

    final List<Map<String, dynamic>> tasksData = [];

    for (final taskDoc in tasksSnapshot.docs) {
      final Map<String, dynamic> taskData = taskDoc.data() as Map<String, dynamic>;
      tasksData.add({
        'documentId': taskDoc.id,
        'task_title': taskData['task_title'],
        'description': taskData['description'],
        'job_type': taskData['job_type'],
        'start_date': taskData['start_date'],
        'end_date': taskData['end_date'],
        'subtasks': taskData['subtasks'] != null ? List.from(taskData['subtasks']) : [],
      });
    }

    return tasksData;
  }
}

class TaskContainer extends StatefulWidget {
  final String documentId;
  final String taskTitle;
  final String description;
  final String job_type;
  final Timestamp start_date;
  final Timestamp end_date;
  final List<dynamic> subtasks;
  final FirebaseFirestore firestore;

  TaskContainer({
    required this.documentId,
    required this.taskTitle,
    required this.description,
    required this.job_type,
    required this.start_date,
    required this.end_date,
    required this.subtasks,
    required this.firestore,
  });

  @override
  _TaskContainerState createState() => _TaskContainerState();
}

class _TaskContainerState extends State<TaskContainer> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = false;
    loadCheckboxState();
  }

  Future<void> loadCheckboxState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = prefs.getBool(widget.documentId) ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateTimeValue = widget.start_date.toDate();
    String formattedStartDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeValue);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPage(
              taskTitle: widget.taskTitle,
              description: widget.description,
              job_type: widget.job_type,
              start_date: widget.start_date,
              end_date: widget.end_date,
              subtasks: widget.subtasks,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  isChecked = !isChecked;
                  _updateTaskCompletionStatus();
                  saveCheckboxState();
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isChecked ? Colors.green : Colors.white,
                  border: Border.all(
                    color: isChecked ? Colors.green : Colors.grey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: isChecked
                      ? Icon(
                    Icons.check,
                    size: 16.0,
                    color: Colors.white,
                  )
                      : Container(),
                ),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Title: ${widget.taskTitle}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Task Type: ${widget.job_type}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateTaskCompletionStatus() {
    widget.firestore.collection('tasks').doc(widget.documentId).update({
      'completed': isChecked,
    });
  }

  Future<void> saveCheckboxState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(widget.documentId, isChecked);
  }
}
