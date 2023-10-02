import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskly_todo/Model/task.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  _HomePageState();

  String? newTaskConstant;
  Box? _box;

  late double _deviceWidth;
  late double _deviceHeight;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: _deviceHeight * 0.15,
        title: const Text(
          "Taskly",
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: _taskView(),
      floatingActionButton: _addTaskButton(),
    );
  }

  Widget _taskView() {
    return FutureBuilder(
      future: Hive.openBox('task'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          _box = snapshot.data;
          return _taskList();
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _taskList() {
    List tasks = _box!.values.toList();
    if (tasks.isEmpty) {
      return const Center(
        child: Text("Nothing to do!"),
      );
    } else {
      return ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          var task = Task.fromMap(tasks[index]);
          return ListTile(
            title: Text(
              task.content,
              style: TextStyle(
                  decoration: task.done ? TextDecoration.lineThrough : null),
            ),
            subtitle: Text(task.timestamp.toString()),
            trailing: Icon(
              task.done
                  ? Icons.check_box_outlined
                  : Icons.check_box_outline_blank_outlined,
              color: Colors.red,
            ),
            onTap: () {
              task.done = !task.done;
              _box?.putAt(index, task.toMap());
              setState(() {});
            },
            onLongPress: () {
              _box?.deleteAt(index);
              setState(() {});
            },
          );
        },
      );
    }
  }

  Widget _addTaskButton() {
    return Container(
      child: FloatingActionButton(
        onPressed: _displayTaskPopup,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _displayTaskPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add new task"),
          content: TextField(
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                var task = Task(
                    content: value, timestamp: DateTime.now(), done: false);
                _box?.add(task.toMap());
                setState(() {
                  Navigator.pop(context);
                });
              } else {
                Navigator.pop(context);
              }
            },
            onChanged: (value) {},
          ),
        );
      },
    );
  }
}
