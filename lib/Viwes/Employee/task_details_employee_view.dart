// task_details_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskDetailsPage extends StatefulWidget {
  final String taskTitle;
  final String description;
  final String job_type;
  final Timestamp start_date;
  final Timestamp end_date;
  final List<dynamic> subtasks;
  //final double price;
  // late double price;
  // final double price;



  TaskDetailsPage({
    required this.taskTitle,
    required this.description,
    required this.job_type,
    required this.start_date,
    required this.end_date,
    required this.subtasks,
    //  required this.price,
    //  required this.price,

  });

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _jobTypeController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _subtasksController;
  // late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.taskTitle);
    _descriptionController = TextEditingController(text: widget.description);
    _jobTypeController = TextEditingController(text: widget.job_type);
    _startDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.start_date.toDate()));
    _endDateController = TextEditingController(
        text: DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.end_date.toDate()));
    _subtasksController = TextEditingController(text: widget.subtasks.join(', '));

    // _priceController = TextEditingController(text: widget.price.toString());



  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _jobTypeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _subtasksController.dispose();
    // _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Colors.indigo[300],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Task Title')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: _jobTypeController, decoration: InputDecoration(labelText: 'Job Type')),
            TextField(controller: _startDateController, decoration: InputDecoration(labelText: 'Start Date')),
            TextField(controller: _endDateController, decoration: InputDecoration(labelText: 'End Date')),
            TextField(controller: _subtasksController, decoration: InputDecoration(labelText: 'Subtasks')),
            //     TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price')),
          ],
        ),
      ),
    );
  }
}
