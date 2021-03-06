import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:Docket/component/datepicker/date_picker_builder.dart';

import 'package:Docket/scopedmodel/todo_list_model.dart';
import 'package:Docket/model/task_model.dart';
import 'package:Docket/component/iconpicker/icon_picker_builder.dart';
import 'package:Docket/component/colorpicker/color_picker_builder.dart';

import '../main.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  final String taskName;
  final Color color;
  final IconData icon;
  final String dated;

  EditTaskScreen(
      {@required this.taskId,
      @required this.taskName,
      @required this.color,
      @required this.dated,
      @required this.icon});

  @override
  State<StatefulWidget> createState() {
    return _EditCardScreenState();
  }
}

class _EditCardScreenState extends State<EditTaskScreen> {
  final btnSaveTitle = "Save Changes";
  String newTask;
  Color taskColor;
  IconData taskIcon;
  IconData alarmIcon;
  String date;
  String time;
  DateTime test;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    initializeNotifications();
    super.initState();
    setState(() {
      test = (DateTime.parse("2012-02-27 13:27:00"));
      date = widget.dated;
      time = '';
      newTask = widget.taskName;
      taskColor = widget.color;
      taskIcon = widget.icon;
      alarmIcon = Icons.add_alarm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TodoListModel>(
      builder: (BuildContext context, Widget child, TodoListModel model) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Edit Category',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black26),
            brightness: Brightness.light,
            backgroundColor: Colors.white,
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 36.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category will help you group related task!',
                  style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0),
                ),
                Container(
                  height: 16.0,
                ),
                TextFormField(
                  initialValue: newTask,
                  onChanged: (text) {
                    setState(() => newTask = text);
                  },
                  cursorColor: taskColor,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Category Name...',
                      hintStyle: TextStyle(
                        color: Colors.black26,
                      )),
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontSize: 36.0),
                ),
                Container(
                  height: 26.0,
                ),
                Row(
                  children: [
                    ColorPickerBuilder(
                        color: taskColor,
                        onColorChanged: (newColor) =>
                            setState(() => taskColor = newColor)),
                    Container(
                      width: 22.0,
                    ),
                    IconPickerBuilder(
                        iconData: taskIcon,
                        highlightColor: taskColor,
                        action: (newIcon) =>
                            setState(() => taskIcon = newIcon)),
                    Container(
                      width: 22.0,
                    ),
                    DatePickerBuilder(
                      iconData: alarmIcon,
                      highlightColor: taskColor,
                      dates: date,
                      pickedDate: (i) => setState(() =>
                          date = (DateFormat('yyyyMMdd').format(i ?? test))),
                      pickedTime: (i) => setState(() =>
                          time = (DateFormat('HH:mm:ss').format(i ?? test))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton.extended(
                heroTag: 'fab_new_card',
                icon: Icon(Icons.save),
                backgroundColor: taskColor,
                label: Text(btnSaveTitle),
                onPressed: () {
                  if (newTask.isEmpty) {
                    final snackBar = SnackBar(
                      content: Text(
                          'Ummm... It seems that you are trying to add an invisible task which is not allowed in this realm.'),
                      backgroundColor: taskColor,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                    // _scaffoldKey.currentState.showSnackBar(snackBar);
                  } else {
                    if (date == "20120227") {
                      date = null;
                      time = null;
                    }
                    if (date == null) {
                      model.updateTask(Task(newTask,
                          codePoint: taskIcon.codePoint,
                          color: taskColor.value,
                          id: widget.taskId));
                    } else {
                      if (time == "") {
                        time = DateFormat('HH:mm')
                            .format(DateTime.parse(widget.dated));
                      }
                      scheduleNotification(Task(newTask,
                          codePoint: taskIcon.codePoint,
                          color: taskColor.value,
                          id: widget.taskId,
                          date: date.toString(),
                          time: time.toString()));
                      model.updateTask(Task(newTask,
                          codePoint: taskIcon.codePoint,
                          color: taskColor.value,
                          id: widget.taskId,
                          date: date,
                          time: time));
                    }
                    Navigator.pop(context);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  initializeNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  Future<void> scheduleNotification(Task task) async {
    DateTime scheduledNotificationDateTime;
    if (date != null) {
      try {
        var _datetime = date + " " + time;
        scheduledNotificationDateTime = (DateTime.parse(_datetime));
      } catch (e) {
        print("failure");
      }
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'your other channel id',
          'your other channel name',
          'your other channel description');
      var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.schedule(0, newTask, 'Reminder',
          scheduledNotificationDateTime, platformChannelSpecifics);
    }
  }
}

// Reason for wraping fab with builder (to get scafold context)
// https://stackoverflow.com/a/52123080/4934757
