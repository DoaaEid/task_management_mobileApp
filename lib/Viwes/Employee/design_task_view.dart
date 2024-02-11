//taskcard.dart

import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
class Task {
  IconData? iconData;
  String? title;
  Color? bgColor;
  Color? iconColor;
  Color? btnColor;
  num? left;
  num? done;
  late bool isLast;
  Task({
    this.iconData ,
    this.title,
    this.bgColor,
    this.iconColor,
    this.btnColor,
    this.left,
    this.done,
    this.isLast = false
  });
  static List<Task> generateTasks(){
    return[
      Task(
        iconData:Icons.task_outlined,
        title:'مهامك',
        bgColor:Colors.indigo[400],
        iconColor:Colors.indigo[200],
        btnColor:Colors.indigo[50],
        left: 3,
        done: 1,

      ),

      Task(
        iconData:Icons.checklist,
        title:'المنجزة',
        bgColor:Colors.deepPurple[400],
        iconColor:Colors.deepPurple[200],
        btnColor:Colors.deepPurple[50],
        left: 0,
        done: 0,

      ),

      Task(
        iconData:Icons.event_repeat,
        title:'تقرير',
        bgColor:Colors.blue[400],
        iconColor:Colors.blue[200],
        btnColor:Colors.blue[50],
        left: 0,
        done: 0,

      ),

      Task(isLast: true),


    ];
  }
}