// D2DCalendarActivityBody.dart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

import 'authority/BDO/BDOD2D/QRDetailsScreen.dart';
import 'authority/BDO/CalnderActivity/BDOSelectedDateActivitiesScreen.dart';

class D2DCalendarActivityBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime(2000),
          lastDay: DateTime(2100),
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          onDaySelected: (selectedDay, focusedDay) =>
              onDateSelected(selectedDay),
        ),
        Expanded(
          child: isLoading
              ? Center(
                  child: Image.asset(
                    'assets/images/Loder.gif',
                    width: 200,
                    height: 200,
                  ),
                )
              : TabBarView(
                  controller: tabController,
                  children: [
                    _buildActivityCard(
                        context,
                        'Total Activities',
                        activities.length,
                        BDOSelectedDateActivitiesScreen(
                            selectedDate: selectedDate,
                            activities: activities)),
                    _buildActivityCard(
                        context,
                        'Total QR Scans',
                        tripDetails.length,
                        QRDetailsScreen(tripDetails: tripDetails)),
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
          child: Text('View All'),
        ),
      ),
    );
  }
}
