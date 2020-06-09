import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/component/todo_badge.dart';
import 'package:todo/page/add_task_screen.dart';

class DatePickerBuilder extends StatelessWidget {
  final IconData iconData;
  final ValueChanged<DateTime> pickedDate;
  final ValueChanged<DateTime> pickedTime;
  final Color highlightColor;

  DatePickerBuilder({
    @required this.iconData,
    @required this.pickedDate,
    @required this.pickedTime,
    Color highlightColor,
  }) : this.highlightColor = highlightColor;

  @override
  Widget build(BuildContext context) {
    //https://stackoverflow.com/questions/45424621/inkwell-not-showing-ripple-effect
    final format = DateFormat("EEE, d MMM yyyy");
    final tformat = DateFormat("HH:mm");
    GlobalKey<FormState> _formKey;
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
                      constraints: BoxConstraints.expand(
                        height: 250,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(13)),
                          color: Colors.white),
                      child: Form(
                        key: _formKey,
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text("Add Reminder"),
                          Container(
                            child: DateTimeField(
                              onChanged: pickedDate,
                              format: format,
                              decoration: InputDecoration(
                                  labelText: 'Date',
                                  hasFloatingPlaceholder: false),
                              onShowPicker: (context, currentValue) async {
                                final date = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    initialDate:
                                        currentValue ?? new DateTime.now(),
                                    lastDate: DateTime(2100));
                                return (date);
                              },
                            ),
                          ),
                          Container(
                            child: DateTimeField(
                              onChanged: pickedTime,
                              format: tformat,
                              decoration: InputDecoration(
                                  labelText: 'Time',
                                  hasFloatingPlaceholder: false),
                              onShowPicker: (context, tcurrentValue) async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.fromDateTime(
                                      tcurrentValue ?? DateTime.now()),
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
                                  "Cancel",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              RaisedButton(
                                color: highlightColor,
                                child: Text("Add",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  if (pickedDate != null) {
                                    if (pickedTime != null) {
                                      print(pickedDate);
                                      print(pickedTime);
                                      Navigator.pop(context);
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      )
                      
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
