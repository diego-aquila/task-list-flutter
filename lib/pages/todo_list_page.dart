import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/models/tasks.dart';
import 'package:todolist/repositories/task_repository.dart';

import '../components/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TaskRepository taskRepository = TaskRepository();

  List<Task> tasks = [];
  Task? deletedTask;
  int? deletedIndex;

  String? errorText;

  @override
  void initState() {
    super.initState();

    taskRepository.getTaskList().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {});

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: todoController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Adicione uma tarefa',
                          hintText: 'Ex. Estudar Flutter',
                          errorText: errorText,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.amberAccent,
                          padding: EdgeInsets.all(14)),
                      onPressed: () {
                        String text = todoController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'O título não pode ser vazio';
                          });
                          return;
                        }

                        setState(() {
                          Task newTask =
                              Task(title: text, date: DateTime.now());
                          tasks.add(newTask);
                          errorText = null;
                        });
                        todoController.clear();
                        taskRepository.saveTaskList(tasks);
                      },
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Task task in tasks)
                        TodoListItem(
                          task: task,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    Expanded(
                      child:
                          Text('Você possui ${tasks.length} tarefas pendentes'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.amberAccent,
                          padding: EdgeInsets.all(14)),
                      onPressed: tasks.isNotEmpty ? showDialogClearAll : null,
                      child: Text('Limpar tudo'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Task task) {
    deletedTask = task;
    deletedIndex = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });
    taskRepository.saveTaskList(tasks);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa ${task.title} foi removida com sucesso!'),
        backgroundColor: Colors.amberAccent,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              tasks.insert(deletedIndex!, deletedTask!);
            });
            taskRepository.saveTaskList(tasks);

            // A exclamação garante que não será nulo
          },
        ),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void clearTasks() {
    setState(() {
      tasks.clear();
    });
    taskRepository.saveTaskList(tasks);
  }

  void showDialogClearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text(
            'Essa ação irá apagar todas as tarefas, vocêm tem certeza disso?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              clearTasks();
            },
            child: Text(
              'Limpar tudo',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
