// employee_task_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:task_management/Model/task_manager_service_model.dart';



class EmployeeTaskPage extends StatefulWidget {
  @override
  _EmployeeTaskPageState createState() => _EmployeeTaskPageState();

}

class _EmployeeTaskPageState extends State<EmployeeTaskPage> {
  Timer? repeatTaskTimer;

  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController subtaskController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  String? selectedTaskType;
  String? selectedEmployee;
  String? selectedRepeatFrequency;
  List<String> employeeNames = [];
  List<String> subtaskDescriptions = [];
  List<String> repeatFrequencies = ['None', 'Daily', 'Weekly', 'Monthly'];

  FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  // late Timer repeatTaskTimer;


  @override
  void initState() {
    super.initState();
    _getUser();
    _getEmployeeNames();

  }


  Future<void> _getUser() async {
    _user = _auth.currentUser!;
  }

  Future<void> _getEmployeeNames() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        employeeNames = querySnapshot.docs
            .where((doc) =>
        (doc.data() as Map<String, dynamic>?)?.containsKey('firstName') ??
            false)
            .map((doc) => doc['firstName'].toString())
            .toList();
      });
    } catch (e) {
      print('Error getting employee names: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }


  void _addTask() {
    if (selectedEmployee != null &&
        selectedTaskType != null &&
        startDate != null &&
        endDate != null &&
        selectedRepeatFrequency != null &&
        descriptionController.text.isNotEmpty &&
        taskTitleController.text.isNotEmpty) {
      int repeatInterval = 0;
      if (selectedRepeatFrequency == 'Daily') {
        repeatInterval = 2 * 60 * 1000; // 2 minutes in milliseconds
      }

      print('Adding task with selectedEmployee: $selectedEmployee');
      print('Adding task with selectedTaskType: $selectedTaskType');

      EmployeeTask task = EmployeeTask(
        taskTitle: taskTitleController.text,
        name: selectedEmployee!,
        startDate: startDate!,
        endDate: endDate!,
        jobType: selectedTaskType!,
        description: descriptionController.text,
        subtasks: List.from(subtaskDescriptions),
        note: noteController.text,
        price: double.parse(priceController.text),
        repeatFrequency: selectedRepeatFrequency!,
      );

      FirebaseFirestore.instance.collection('tasks').add({
        'task_title': task.taskTitle,
        'firstName': task.name,
        'job_type': task.jobType,
        'subtasks': task.subtasks,
        'start_date': task.startDate,
        'end_date': task.endDate,
        'description': task.description,
        'note': task.note,
        'price': task.price,
        'repeat_frequency': task.repeatFrequency,
        'user_id': _user.uid,
      });

      repeatTaskTimer = Timer.periodic(Duration(milliseconds: repeatInterval), (timer) {
        print('Repeating task timer callback executed.');

        if (selectedEmployee != null && selectedTaskType != null) {
          DateTime newStartDate = task.startDate.add(Duration(milliseconds: repeatInterval));
          DateTime newEndDate = task.endDate.add(Duration(milliseconds: repeatInterval));

          EmployeeTask repeatedTask = EmployeeTask(
            taskTitle: task.taskTitle,
            name: selectedEmployee!,
            startDate: newStartDate,
            endDate: newEndDate,
            jobType: task.jobType,
            description: task.description,
            subtasks: task.subtasks,
            note: task.note,
            price: task.price,
            repeatFrequency: task.repeatFrequency,
          );

          FirebaseFirestore.instance.collection('tasks').add({
            'task_title': repeatedTask.taskTitle,
            'firstName': repeatedTask.name,
            'job_type': repeatedTask.jobType,
            'subtasks': repeatedTask.subtasks,
            'start_date': repeatedTask.startDate,
            'end_date': repeatedTask.endDate,
            'description': repeatedTask.description,
            'note': repeatedTask.note,
            'price': repeatedTask.price,
            'repeat_frequency': repeatedTask.repeatFrequency,
            'user_id': _user.uid,
          });
        } else {
          print('Error: selectedEmployee or selectedTaskType is null.');
          timer.cancel(); // Cancel the timer if there's an error
        }
      });

      taskTitleController.clear();
      descriptionController.clear();
      subtaskController.clear();
      noteController.clear();
      priceController.clear();
      setState(() {
        startDate = null;
        endDate = null;
        selectedTaskType = null;
        selectedEmployee = null;
        selectedRepeatFrequency = null;
        subtaskDescriptions.clear();
      });
    } else {
      print('Error: Some required fields are null or empty.');
      if (selectedEmployee == null) {
        print('selectedEmployee is null');
      }
      if (selectedTaskType == null) {
        print('selectedTaskType is null');
      }
      if (startDate == null) {
        print('startDate is null');
      }
      if (endDate == null) {
        print('endDate is null');
      }
      if (selectedRepeatFrequency == null) {
        print('selectedRepeatFrequency is null');
      }
      if (descriptionController.text.isEmpty) {
        print('descriptionController is empty');
      }
      if (taskTitleController.text.isEmpty) {
        print('taskTitleController is empty');
      }
    }
  }




  void _addSubtask() {
    if (subtaskController.text.isNotEmpty) {
      setState(() {
        subtaskDescriptions.add(subtaskController.text);
        subtaskController.clear();
      });
    }
  }

  @override
  void dispose() {
    repeatTaskTimer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مهام الموظفين'),
        backgroundColor: Colors.indigo[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: taskTitleController,
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18.0,
                color: Colors.blueGrey,
              ),
              decoration: InputDecoration(
                labelText: 'عنوان المهمة',
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
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedEmployee,
              onChanged: (String? value) {
                setState(() {
                  selectedEmployee = value;
                });
              },
              items: employeeNames
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 16.0,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'اسم الموظف',
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
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedTaskType,
              onChanged: (String? value) {
                setState(() {
                  selectedTaskType = value;
                });
              },
              items: ['Motivational', 'Fixed', 'Routine', 'Periodic']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 16.0,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              )
                  .toList(),
              decoration: InputDecoration(
                labelText: 'نوع المهمة',
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

            //pric
            SizedBox(height: 20),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18.0,
                color: Colors.blueGrey,
              ),
              decoration: InputDecoration(
                labelText: 'السعر',
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
///////




            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المهام الفرعية',
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 16.0,
                          color: Colors.blueGrey,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: subtaskController,
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 18.0,
                          color: Colors.blueGrey,
                        ),
                        decoration: InputDecoration(
                          labelText: 'المهمة الفرعية',
                          labelStyle: TextStyle(
                            fontFamily: 'Pacifico',
                            fontSize: 16.0,
                            color: Colors.blueGrey,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSubtask,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.indigo[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'اضف المهمة',
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ),
            if (subtaskDescriptions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    'مهمة فرعيه:',
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 18.0,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: subtaskDescriptions
                        .map((subtask) => Text(
                      '- $subtask',
                      style: TextStyle(
                        fontFamily: 'Pacifico',
                        fontSize: 16.0,
                        color: Colors.blueGrey,
                      ),
                    ))
                        .toList(),
                  ),
                ],
              ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                          text: startDate != null
                              ? startDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 18.0,
                          color: Colors.blueGrey,
                        ),
                        decoration: InputDecoration(
                          labelText: 'تاريخ البدأ',
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
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        controller: TextEditingController(
                          text: endDate != null
                              ? endDate!.toLocal().toString().split(' ')[0]
                              : '',
                        ),
                        style: TextStyle(
                          fontFamily: 'Pacifico',
                          fontSize: 18.0,
                          color: Colors.blueGrey,
                        ),
                        decoration: InputDecoration(
                          labelText: 'تاريخ الانتهاء',
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
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18.0,
                color: Colors.blueGrey,
              ),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'وصف',
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
            SizedBox(height: 20),
            TextField(
              controller: noteController,
              style: TextStyle(
                fontFamily: 'Pacifico',
                fontSize: 18.0,
                color: Colors.blueGrey,
              ),
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'ملاحظة',
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



            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedRepeatFrequency,
              onChanged: (String? value) {
                setState(() {
                  selectedRepeatFrequency = value;
                });
              },
              items: repeatFrequencies.map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ),
              ).toList(),
              decoration: InputDecoration(
                labelText: 'تكرار المهمة',
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







            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addTask,
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Add Task',
                style: TextStyle(
                  fontFamily: 'Pacifico',
                  fontSize: 20.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }




}