// button_items.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_2/l10n/generated/app_localizations.dart';

List<Map<String, dynamic>> buttonItems(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;

  return [
    {
      'label': localizations.door_to_door,
      'imageUrl': 'assets/images/d2d.png',
      'route': 'DoorToDoorScreen'
    },
    {
      'label': localizations.road_sweeping,
      'imageUrl': 'assets/images/road_sweeping.png',
      'route': 'RoadSweepingScreen'
    },
    {
      'label': localizations.drain_cleaning,
      'imageUrl': 'assets/images/drainage_collectin.png',
      'route': 'DrainCleaningScreen'
    },
    {
      'label': localizations.community_service_centre,
      'imageUrl': 'assets/images/CSC.png',
      'route': 'CSCScreen'
    },
    {
      'label': localizations.resource_recovery_centre,
      'imageUrl': 'assets/images/RRC.png',
      'route': 'RRCScreen'
    },
    {
      'label': localizations.wages,
      'imageUrl': 'assets/images/wages.png',
      'route': 'WagesScreen'
    },
    {
      'label': localizations.school_campus_sweeping,
      'imageUrl': 'assets/images/SchoolCampus.png',
      'route': 'SchoolCampus'
    },
    {
      'label': localizations.panchayat_campus,
      'imageUrl': 'assets/images/PanchayatCampus.png',
      'route': 'PanchayatCampus'
    },
    {
      'label': localizations.animal_body_transport,
      'imageUrl': 'assets/images/AnimalBodytransport.png',
      'route': 'AnimalBodytransport'
    },
    {
      'label': localizations.contractor_details,
      'imageUrl': 'assets/images/Contractors.png',
      'route': 'ContractorDetailsScreen'
    },
  ];
}
