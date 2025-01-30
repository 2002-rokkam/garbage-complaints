// RotatingTrashBinLoader.dart
import 'package:flutter/material.dart';

class SweepingBroomLoader extends StatefulWidget {
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
      begin: Offset(-1.0, 0.0),
      end: Offset(1.0, 0.0),
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
      child: Icon(
        Icons.cleaning_services,
        size: 50,
        color: Colors.brown,
      ),
    );
  }
}
