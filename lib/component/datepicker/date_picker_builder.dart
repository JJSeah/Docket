import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/component/todo_badge.dart';

class DatePickerBuilder extends StatelessWidget {
  final IconData iconData;
  final ValueChanged<IconData> action;
  final Color highlightColor;
  DateTime pickedDate;
  TimeOfDay time;

  DatePickerBuilder({
    @required this.iconData,
    @required this.action,
    Color highlightColor,
  }) : this.highlightColor = highlightColor;

  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/45424621/inkwell-not-showing-ripple-effect
    TextEditingController taskName = new TextEditingController();
    TextEditingController deadline = new TextEditingController();
    final format = DateFormat("dd-MM-yy");
    final tformat = DateFormat("HH:mm");
    return ClipOval(
      child: Container(
        child: Material(
          child: InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13.0))),
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
                          Text("Add Reminder"),
                          Container(
                            child: DateTimeField(
                              format: format,
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    initialDate:
                                        currentValue ?? new DateTime.now(),
                                    lastDate: DateTime(2100));
                              },
                            ),
                          ),
                          Container(
                            child: DateTimeField(
                              format: tformat,
                              onShowPicker: (context, currentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      currentValue ?? DateTime.now()),
                                );
                                return DateTimeField.convert(time);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                color: highlightColor,
                                child: Text(
                                  "Cancel",style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              RaisedButton(
                                color: highlightColor,
                                child: Text(
                                  "Add",style: TextStyle(color: Colors.white)
                                ),
                                onPressed: () {
                                  // if (taskName.text != null) {
                                  //   addTask(taskName.text, deadline.text);
                                  //   Navigator.pop(context);
                                  // }
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
            },
            child: TodoBadge(
              id: 'ids',
              codePoint: iconData.codePoint,
              color: highlightColor,
              outlineColor: highlightColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
