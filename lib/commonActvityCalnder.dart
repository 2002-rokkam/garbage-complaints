// commonActvityCalnder.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

class ActivityCalendar extends StatefulWidget {
  final String section;
  final DateTime initialDate;
  final List activities;
  final Map<DateTime, int> activityCounts;
  final Function(DateTime) onDateSelected;

  const ActivityCalendar({
    Key? key,
    required this.section,
    required this.initialDate,
    required this.activities,
    required this.activityCounts,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _ActivityCalendarState createState() => _ActivityCalendarState();
}

class _ActivityCalendarState extends State<ActivityCalendar> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  List getActivitiesForSelectedDate() {
    return widget.activities
        .where((activity) =>
            DateTime.parse(activity['date_time']).toLocal().day ==
                _selectedDate.day &&
            DateTime.parse(activity['date_time']).toLocal().month ==
                _selectedDate.month &&
            DateTime.parse(activity['date_time']).toLocal().year ==
                _selectedDate.year)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivities = getActivitiesForSelectedDate();

    return Column(
      children: [
        TableCalendar(
          focusedDay: _selectedDate,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
            });
            widget.onDateSelected(selectedDay);
          },
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFF5C964A),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              final count = widget.activityCounts[
                      DateTime(date.year, date.month, date.day)] ??
                  0;

              if (count > 0) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        selectedActivities.isNotEmpty
            ? Container()
            : const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No activities for selected date.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
      ],
    );
  }
}
