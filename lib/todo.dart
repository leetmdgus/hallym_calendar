import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chatbot.dart';
import 'setting.dart';
import 'calendar.dart';
import 'dart:convert';

class ToDoScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ToDoState();
  }
}

class _ToDoState extends State<ToDoScreen> {
  var textFontSize = 30.0;

  late List<bool> checkBoxState = [];
  late List<dynamic> plans = [];
  late SharedPreferences prefs;

  getInitState() async {
    prefs = await SharedPreferences.getInstance();

    // 체크박스 가져오기
    checkBoxState = List.empty(growable: true);

    for (int i = 0; i < plans.length; i++) {
      checkBoxState.add(prefs.getBool('$userEmail $i') ?? false);
    }
    checkBoxStateIdx = plans.length;

    // fontsize 가져오기
    textFontSize = prefs.getDouble('$userEmail fontSize') ?? 30.0;
    setState(() {});
  }

  int checkBoxStateIdx = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      plans = selectedEvents;
      getInitState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = CalendarState.of(context);
    return Scaffold(
      body: Container(
        color: isSunnyMode ? Colors.white : Colors.black87,
        child: ListView.builder(
          itemCount: plans.length,
          itemBuilder: (contents, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    checkBoxState[index] = !checkBoxState[index];
                  });
                  await prefs.setBool(
                      '$userEmail $index', checkBoxState[index]);
                },
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          calendarState?.deleteEvent(
                              DateTime(DateTime.now().year,
                                  DateTime.now().month, DateTime.now().day),
                              index);
                          plans.removeAt(index);
                          saveEvents();
                          setState(() {});
                        });
                      },
                      child: Icon(Icons.cancel),
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        child: Text(
                          '${plans[index][0] ?? ''} ${plans[index][1] ?? ''}',
                          style: TextStyle(
                              fontSize: textFontSize,
                              decoration: checkBoxState[index]
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: isSunnyMode ? Colors.black : Colors.grey),
                        ),
                      ),
                    ),
                    Spacer(),
                    Checkbox(
                      value: checkBoxState[index],
                      onChanged: (value) async {
                        setState(() {
                          checkBoxState[index] = value as bool;
                        });
                        await prefs.setBool(
                            '${userEmail} $index', checkBoxState[index]);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ChatScreen()));
        },
        child: Icon(isSunnyMode ? Icons.message_outlined : Icons.message),
      ),
    );
  }
}
