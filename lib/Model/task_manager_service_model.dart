// employee_task.dart

class EmployeeTask {
  late String taskTitle;
  late String name;
  late DateTime startDate;
  late DateTime endDate;
  late String jobType;
  late String description;
  List<String> subtasks;
  late String note;
  late double price;
  late String repeatFrequency;


  EmployeeTask({
    required this.taskTitle,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.jobType,
    required this.description,
    this.subtasks = const [],
    required this.note,
    required this.price,
    required this.repeatFrequency,

  });
}
