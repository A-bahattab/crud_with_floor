import 'package:crud_with_floor/add_task.dart';
import 'package:crud_with_floor/app_database.dart';
import 'package:crud_with_floor/todo_dao.dart';
import 'package:crud_with_floor/todo_entity.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  TodoDao? _todoDao;
  List<Todo> todoList = [];

  final database = $FloorAppDatabase.databaseBuilder('todo.db').build();

  HomePage({Key? key, required this.homeTitle}) : super(key: key);

  final String homeTitle;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.homeTitle),
        actions: [
          IconButton(
              onPressed: () {
                List<Todo> listSelected = widget.todoList
                    .where((element) => element.isSelect == true)
                    .toList();
                widget._todoDao!.deleteAll(listSelected).then((value) {
                  setState(() {});
                });
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder(
        future: _callTodo(),
        builder: (BuildContext context, AsyncSnapshot<TodoDao> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.none) {
            return CircularProgressIndicator();
          } else {
            return StreamBuilder(
              stream: snapshot.data!.streamedData(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.connectionState == ConnectionState.none) {
                  return CircularProgressIndicator();
                } else {
                  if (widget.todoList.length != snapshot.data!.length) {
                    widget.todoList = snapshot.data!;
                  }
                  if (snapshot.data!.isEmpty) {
                    return Center(child: Text('No Data Found'));
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          //color: Colors.transparent,
                          //shadowColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              //color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: widget.todoList[index].isSelect,
                                onChanged: (value) {
                                  setState(() {
                                    widget.todoList[index].isSelect = value!;
                                  });
                                },
                              ),
                              title: Text(snapshot.data![index].task),
                              subtitle: Text(
                                snapshot.data![index].time,
                                style: TextStyle(fontSize: 10),
                              ),
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return AddTask(
                                            id: snapshot.data![index].id,
                                            task: snapshot.data![index].task,
                                          );
                                        })).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _deleteTask(snapshot.data![index].id);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        child: Icon(Icons.add),
      ),
    );
  }

  _openAddTask() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddTask();
    })).then((value) {
      setState(() {});
    });
  }

  void _deleteTask(int id) {
    widget._todoDao!.deleteTodo(id);
    setState(() {});
  }

  Future<TodoDao> _callTodo() async {
    AppDatabase appDatabase = await widget.database;
    widget._todoDao = appDatabase.todoDao;
    return appDatabase.todoDao;
  }
}
