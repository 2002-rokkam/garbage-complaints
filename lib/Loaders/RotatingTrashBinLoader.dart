// RotatingTrashBinLoader.dart
import 'package:flutter/material.dart';
// import 'package:flutter_application_2/l10n/generated/app_localizations.dart';

class SweepingBroomLoader extends StatefulWidget {
  const SweepingBroomLoader({super.key});

  @override
  _SweepingBroomLoaderState createState() => _SweepingBroomLoaderState();
}

class _SweepingBroomLoaderState extends State<SweepingBroomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: const Icon(
        Icons.cleaning_services,
        size: 50,
        color: Colors.brown,
      ),
    );
  }
}
