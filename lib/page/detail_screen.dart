import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:todo/model/todo_model.dart';

import 'package:todo/scopedmodel/todo_list_model.dart';
import 'package:todo/task_progress_indicator.dart';
import 'package:todo/component/todo_badge.dart';
import 'package:todo/model/hero_id_model.dart';
import 'package:todo/model/task_model.dart';
import 'package:todo/utils/color_utils.dart';
import 'package:todo/page/edit_task_screen.dart';

class DetailScreen extends StatefulWidget {
  final String taskId;
  final HeroId heroIds;

  DetailScreen({
    @required this.taskId,
    @required this.heroIds,
  });

  @override
  State<StatefulWidget> createState() {
    return _DetailScreenState();
  }
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _animation;
  TodoListModel model = TodoListModel();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0.0, 0.0))
        .animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, Widget child, TodoListModel model) {
        Task _task;
        TextEditingController textEditingController = TextEditingController();

        try {
          _task = model.tasks.firstWhere((it) => it.id == widget.taskId);
        } catch (e) {
          return Container(
            color: Colors.white,
          );
        }

        var _todos = model.todos
            .where((it) => it.parent == widget.taskId && it.isCompleted == 0)
            .toList();
        var _dones = model.todos
            .where((it) => it.parent == widget.taskId && it.isCompleted == 1)
            .toList();
        var _hero = widget.heroIds;
        var _color = ColorUtils.getColorFrom(id: _task.color);
        var _icon = IconData(_task.codePoint, fontFamily: 'MaterialIcons');

        void _showAddDialog(Todo todo) {
          String taskName;
          TextEditingController deadline = new TextEditingController();
          // flutter defined function
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                content: Container(
                  padding: EdgeInsets.all(20),
                  constraints: BoxConstraints.expand(
                    height: 250,
                  ),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(13)),
                      color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Edit Task"),
                      Container(
                        child: TextField(
                          controller: TextEditingController()..text = todo.name,
                          onChanged: (text) => {taskName = text},
                          decoration: InputDecoration(
                            hintText: "Name of task",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _color),
                            ),
                          ),
                        ),
                      ),
                      // Container(
                      //     child: TextField(
                      //       controller: deadline,
                      //       decoration: InputDecoration(
                      //         hintText: "Deadline",
                      //         enabledBorder: UnderlineInputBorder(
                      //       borderSide: BorderSide(color: Colors.white),
                      //       ),
                      //       ),
                      //     ),
                      // ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            color: _color,
                            child: Text("Cancel",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          RaisedButton(
                            color: _color,
                            child: Text("Confirm",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              if (taskName != null) {
                                model.updateTodo(todo.copy(name: taskName));
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }

        return Theme(
          data: ThemeData(primarySwatch: _color),
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black26),
              brightness: Brightness.light,
              backgroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.edit),
                  color: _color,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(
                          taskId: _task.id,
                          taskName: _task.name,
                          icon: _icon,
                          color: _color,
                        ),
                      ),
                    );
                  },
                ),
                SimpleAlertDialog(
                  color: _color,
                  onActionPressed: () => model.removeTask(_task),
                ),
              ],
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0),
              child: Column(children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 36.0, vertical: 0.0),
                  height: 170,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TodoBadge(
                        color: _color,
                        codePoint: _task.codePoint,
                        id: _hero.codePointId,
                      ),
                      Spacer(
                        flex: 1,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 4.0),
                        child: Hero(
                          tag: _hero.remainingTaskId,
                          child: Text(
                            "${model.getTotalTodosFrom(_task)} Task",
                            style: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(color: Colors.grey[500]),
                          ),
                        ),
                      ),
                      Container(
                        child: Hero(
                          tag: 'title_hero_unused', //_hero.titleId,
                          child: Text(_task.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .title
                                  .copyWith(color: Colors.black54)),
                        ),
                      ),
                      Spacer(),
                      Hero(
                        tag: _hero.progressId,
                        child: TaskProgressIndicator(
                          color: _color,
                          progress: model.getTaskCompletionPercent(_task),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 4.0),
                        child: TextField(
                          minLines: 1,
                          maxLines: 1,
                          decoration: InputDecoration(
                            hintText: '+ New Item',
                            border: UnderlineInputBorder(
                                borderSide: new BorderSide(
                                    color: Color.fromRGBO(173, 179, 191, 1),
                                    width: 0.5,
                                    style: BorderStyle.none)),
                          ),
                          textInputAction: TextInputAction.done,
                          controller: textEditingController,
                          onSubmitted: (String s) {
                            if (s != "") {
                              model.addTodo(Todo(
                                s,
                                parent: _task.id,
                              ));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 20.0),
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        if (index == _todos.length) {
                          return SizedBox(
                            height: 56, // size of FAB
                          );
                        }
                        var todo = _todos[index];
                        return Container(
                          padding: EdgeInsets.only(left: 22.0, right: 22.0),
                          child: ListTile(
                            onTap: () => model.updateTodo(todo.copy(
                                isCompleted: todo.isCompleted == 1 ? 0 : 1)),
                            onLongPress: () => _showAddDialog(todo),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 8.0),
                            leading: Checkbox(
                                onChanged: (value) => model.updateTodo(
                                    todo.copy(isCompleted: value ? 1 : 0)),
                                value: todo.isCompleted == 1 ? true : false),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () => model.removeTodo(todo),
                            ),
                            title: Text(
                              todo.name,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: todo.isCompleted == 1
                                    ? _color
                                    : Colors.black54,
                                decoration: todo.isCompleted == 1
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: _todos.length,
                    ),
                  ),
                ),
                Expanded(
                  child: ExpansionTile(
                    title: new Text(
                      "Dones",
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.grey[500]),
                    ),
                    children: <Widget>[
                      Container(
                        height: 114.27,
                        child: ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _dones.length) {
                              return SizedBox(
                                height: 56, // size of FAB
                              );
                            }
                            var dones = _dones[index];
                            return Container(
                              padding: EdgeInsets.only(left: 22.0, right: 22.0),
                              child: ListTile(
                                onTap: () => model.updateTodo(dones.copy(
                                    isCompleted:
                                        dones.isCompleted == 1 ? 0 : 1)),
                                onLongPress: () => _showAddDialog(dones),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 8.0),
                                leading: Checkbox(
                                    onChanged: (value) => model.updateTodo(
                                        dones.copy(isCompleted: value ? 1 : 0)),
                                    value:
                                        dones.isCompleted == 1 ? true : false),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete_outline),
                                  onPressed: () => model.removeTodo(dones),
                                ),
                                title: Text(
                                  dones.name,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w600,
                                    color: dones.isCompleted == 1
                                        ? _color
                                        : Colors.black54,
                                    decoration: dones.isCompleted == 1
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: _dones.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(Todo todo) {
    String taskName;
    TextEditingController deadline = new TextEditingController();
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints.expand(
              height: 250,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(13)),
                color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Edit Task"),
                Container(
                  child: TextField(
                    controller: TextEditingController()..text = todo.name,
                    onChanged: (text) => {taskName = text},
                    decoration: InputDecoration(
                      hintText: "Name of task",
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Container(
                //     child: TextField(
                //       controller: deadline,
                //       decoration: InputDecoration(
                //         hintText: "Deadline",
                //         enabledBorder: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Colors.white),
                //       ),
                //       ),
                //     ),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      color: Colors.red,
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Colors.red,
                      child: Text("Add"),
                      onPressed: () {
                        if (taskName != null) {
                          model.updateTodo(todo.copy(name: taskName));
                          // print(todo.name);
                          // addTask(taskName.text, deadline.text);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

typedef void Callback();

class SimpleAlertDialog extends StatelessWidget {
  final Color color;
  final Callback onActionPressed;

  SimpleAlertDialog({
    @required this.color,
    @required this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: color,
      icon: Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Delete this card?'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                        'This is a one way street! Deleting this will remove all the task assigned in this card.'),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('Delete'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    onActionPressed();
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
                  textColor: Colors.grey,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
