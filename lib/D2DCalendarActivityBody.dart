// D2DCalendarActivityBody.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

import 'authority/BDO/BDOD2D/QRDetailsScreen.dart';
import 'authority/BDO/CalnderActivity/BDOSelectedDateActivitiesScreen.dart';

class D2DCalendarActivityBody extends StatefulWidget {
  final DateTime selectedDate;
  final List activities;
  final List tripDetails;
  final bool isLoading;
  final TabController tabController;
  final Function(DateTime) onDateSelected;

  const D2DCalendarActivityBody({
    Key? key,
    required this.selectedDate,
    required this.activities,
    required this.tripDetails,
    required this.isLoading,
    required this.tabController,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  _D2DCalendarActivityBodyState createState() =>
      _D2DCalendarActivityBodyState();
}

class _D2DCalendarActivityBodyState extends State<D2DCalendarActivityBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: widget.selectedDate,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(day, widget.selectedDate),
          onDaySelected: (selectedDay, focusedDay) =>
              widget.onDateSelected(selectedDay),
        ),
        Expanded(
          child: widget.isLoading
              ? Center(
                  child: Image.asset(
                    'assets/images/Loder.gif',
                    width: 200,
                    height: 200,
                  ),
                )
              : TabBarView(
                  controller: widget.tabController,
                  children: [
                    _buildActivityCard(
                        context,
                        'Total Activities',
                        widget.activities.length,
                        BDOSelectedDateActivitiesScreen(
                            selectedDate: widget.selectedDate,
                            activities: widget.activities)),
                    _buildActivityCard(
                        context,
                        'Total QR Scans',
                        widget.tripDetails.length,
                        QRDetailsScreen(tripDetails: widget.tripDetails)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(
      BuildContext context, String title, int count, Widget screen) {
    return Card(
      child: ListTile(
        title: Text('$title: $count'),
        trailing: ElevatedButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen)),
          child: const Text('View All'),
        ),
      ),
    );
  }
}
