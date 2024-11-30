import 'package:flutter/material.dart';
import 'package:location_tracking_app/google_map_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Location Tracker",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 22, 28, 112),
        ),
        body: GoogleMapScreen(),
      ),
    );
  }
}
