import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> taskDetails;
  final String? documentId; // Add this line

  const TaskDetailsPage({Key? key, required this.taskDetails, this.documentId}) : super(key: key);

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late DocumentReference taskDocument;
  Stream<DocumentSnapshot<Map<String, dynamic>>>? taskStream;

  late Map<String, dynamic> originalTaskDetails;
  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    originalTaskDetails = Map.from(widget.taskDetails);
    taskDocument = FirebaseFirestore.instance.collection('tasks').doc(widget.documentId);
    taskStream = taskDocument.snapshots() as Stream<DocumentSnapshot<Map<String, dynamic>>>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل المهمة'),
        backgroundColor: Colors.indigo[300],
        actions: [
          isEditing
              ? IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _saveChanges();
            },
          )
              : IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = true;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _confirmDelete();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: taskStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(), // Display loading spinner
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error.toString()}'),
              );
            }

            final taskData = snapshot.data?.data() as Map<String, dynamic>;

            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  taskDetailRow('عنوان المهمة', 'task_title', taskData),
                  taskDetailRow('الاسم الاول', 'firstName', taskData),
                  taskDetailRow('الاسم الاخير', 'job_type', taskData),
                  taskDetailRow('السعر', 'price', taskData),
                  taskDetailRow('تاريخ البدأ', 'start_date', taskData),
                  taskDetailRow('تاريخ الانتهاء', 'end_date', taskData),
                  taskDetailRow('المهام الفرعية', 'subtasks', taskData),
                  taskDetailRow('وصف', 'description', taskData),
                  taskDetailRow('ملاحظه', 'note', taskData),
                  taskDetailRow('انجاز المهمة', 'completed', taskData), // Show the "completed" field
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  Widget taskDetailRow(String label, String field, Map<String, dynamic> taskData) {
    String formattedValue = '';

    if (taskData[field] is Timestamp) {
      DateTime dateTimeValue = taskData[field]?.toDate() ?? DateTime.now();
      formattedValue = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeValue);
    } else if (field == 'completed') {
      formattedValue = taskData[field] == true ? 'قام الموظف بانجاز المهمة' : 'لم يقم الموظف بانجاز المهمة حتى الان';
    } else {
      formattedValue = taskData[field]?.toString() ?? '';
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          isEditing
              ? Container(
            width: 200,
            child: TextField(
              controller: TextEditingController(text: formattedValue),
              onChanged: (value) {
                taskData[field] = value;
              },
              style: TextStyle(
                fontSize: 16,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                isDense: true,
              ),
            ),
          )
              : Text(
            formattedValue,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }


  void _saveChanges() async {
    String? taskId = widget.documentId;

    try {
      if (taskId != null && taskId.isNotEmpty) {
        // Set isLoading to true when starting the save operation
        setState(() {
          isLoading = true;
        });

        Map<String, dynamic> updatedData = {};

        widget.taskDetails.forEach((key, value) {
          if (widget.taskDetails[key] != originalTaskDetails[key]) {
            if (widget.taskDetails[key] != null) {
              updatedData[key] = widget.taskDetails[key];
            }
          }
        });

        if (updatedData.isNotEmpty) {
          await FirebaseFirestore.instance.collection('tasks').doc(taskId).update(updatedData);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Changes saved successfully'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No changes made'),
            ),
          );
        }

        setState(() {
          isEditing = false;
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Document ID is empty or null'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: $e'),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteTask();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask() async {
    String? taskId = widget.documentId;

    try {
      if (taskId != null && taskId.isNotEmpty) {
        // Set isLoading to true when starting the delete operation
        setState(() {
          isLoading = true;
        });

        await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task deleted successfully'),
          ),
        );

        Navigator.pop(context);

        setState(() {
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Document ID is empty or null'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting task: $e'),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }
}
