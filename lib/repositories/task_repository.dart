import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tasks.dart';

class TaskRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Task>> getTaskList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString('task_list') ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Task.fromJson(e)).toList();
  }

  void saveTaskList(List<Task> tasks) {
    final stringJson = json.encode(tasks);
    sharedPreferences.setString('task_list', stringJson);
  }
}
