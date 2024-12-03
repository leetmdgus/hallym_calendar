import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'setting.dart';

class CalendarState extends InheritedWidget {
  final Map<DateTime, List<dynamic>> kEvents;
  final Function(DateTime, int) deleteEvent;

  CalendarState({
    required this.kEvents,
    required this.deleteEvent,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(covariant CalendarState oldWidget) {
    return oldWidget.kEvents != kEvents;
  }

  static CalendarState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CalendarState>();
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CalendarScreenState();
  }
}


Future<void> saveEvents() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> stringEvents = {};

  kEvents.forEach((key, value) {
    stringEvents[key.toIso8601String()] = jsonEncode(value);
  });
  await prefs.setString('${userEmail}_events', jsonEncode(stringEvents));
}

Future<void> loadEvents() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? eventsString = prefs.getString('${userEmail}_events');

  if (eventsString != null) {
    Map<String, dynamic> stringEvents = jsonDecode(eventsString);
    kEvents = {};
    stringEvents.forEach((key, value) {
      kEvents[DateTime.parse(key)] = List<dynamic>.from(jsonDecode(value));
    });
  }

  saveEvents();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadEvents().then((_) {
      setState(() {
        selectedEvents = kEvents[DateTime(
            _selectedDay.year, _selectedDay.month, _selectedDay.day)] ??
            [];
      });
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      selectedEvents = kEvents[DateTime(
          _selectedDay.year, _selectedDay.month, _selectedDay.day)] ??
          [];
    });
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();

        TextEditingController _timeController = TextEditingController();
        TextEditingController _eventController = TextEditingController();

        return AlertDialog(
          title: Row(
            children: [
              Text("[${_selectedDay.month}/${_selectedDay.day}] 일정 추가"),
              Spacer(),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(labelText: '시간'),
                      ),
                      TextFormField(
                        controller: _eventController,
                        decoration: InputDecoration(labelText: '일정'),
                        validator: (value) {
                          return (value?.isEmpty ?? false)
                              ? '내용을 입력해주세요'
                              : null;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (kEvents[DateTime(_selectedDay.year, _selectedDay.month,
                      _selectedDay.day)] ==
                      null) {
                    kEvents[DateTime(_selectedDay.year, _selectedDay.month,
                        _selectedDay.day)] = [];
                  }

                  kEvents[DateTime(_selectedDay.year, _selectedDay.month,
                      _selectedDay.day)]!
                      .add(
                    [_timeController.text, _eventController.text],
                  );

                  selectedEvents = kEvents[DateTime(_selectedDay.year,
                      _selectedDay.month, _selectedDay.day)]!;
                  _timeController.clear();
                  _eventController.clear();
                  setState(() {});
                  saveEvents();
                  Navigator.of(context).pop();
                }
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  void deleteEvent(DateTime selectedDay, int index) {
    setState(() {
      DateTime eventDate =
      DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      if (kEvents[eventDate] != null && kEvents[eventDate]!.length > index) {
        kEvents[eventDate]!.removeAt(index);
        if (kEvents[eventDate]!.isEmpty) {
          kEvents.remove(eventDate);
        }
        selectedEvents = kEvents[eventDate] ?? [];
        saveEvents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarState(
      kEvents: kEvents,
      deleteEvent: deleteEvent,
      child: Scaffold(
        body: Container(
          color: isSunnyMode ? Colors.white : Colors.black87,
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2021, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: _onDaySelected,
                headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        color: isSunnyMode ? Colors.black : Colors.white),
                    formatButtonVisible: false,
                    titleCentered: true),
                eventLoader: (day) {
                  return kEvents[DateTime(day.year, day.month, day.day)] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: (context, day) {
                    switch (day.weekday) {
                      case 1:
                        return Center(
                            child: Text(
                              '월',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 2:
                        return Center(
                            child: Text(
                              '화',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 3:
                        return Center(
                            child: Text(
                              '수',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 4:
                        return Center(
                            child: Text(
                              '목',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 5:
                        return Center(
                            child: Text(
                              '금',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 6:
                        return Center(
                            child: Text(
                              '토',
                              style: TextStyle(
                                  color: isSunnyMode ? Colors.black : Colors.white),
                            ));
                      case 7:
                        return Center(
                          child: Text(
                            '일',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                    }
                    return null;
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: _buildEventsMarker(date, events),
                      );
                    }
                    return null;
                  },
                  defaultBuilder: (context, date, focusedDay) {
                    return Container(
                        alignment: Alignment.center,
                        child: Text('${date.day}',
                            style: TextStyle(
                                color: isSunnyMode
                                    ? Colors.black
                                    : Colors.white)));
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: selectedEvents.length,
                  itemBuilder: (context, index) {
                    final event = selectedEvents[index];
                    return ListTile(
                      title: Text(
                        '${event[0]}: ${event[1]}',
                        style: TextStyle(
                            color: isSunnyMode ? Colors.black : Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteEvent(_selectedDay, index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addEvent,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      width: 12.0,
      height: 12.0,
      child: Center(
        child: Text('${events.length}',
            style: TextStyle(color: Colors.white, fontSize: 8)),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CalendarScreen(),
  ));
}
