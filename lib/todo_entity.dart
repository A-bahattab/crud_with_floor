import 'package:floor/floor.dart';

@entity
class Todo {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String task;
  final String time;
  final String schecdulaTime;

  @ignore
  bool isSelect = false;

  Todo(this.id, this.task, this.time, this.schecdulaTime);
}
