import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy New Year!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewYearsCountdownScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewYearsCountdownScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Landscape(),
    );
  }
}

class Landscape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSky(),
        _buildStars(),
        _buildMountains(),
      ],
    );
  }

  Widget _buildSky() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: _buildGradient(),
      ),
      child: SizedBox.expand(),
    );
  }

  LinearGradient _buildGradient() {
    return LinearGradient(
      colors: [
        const Color(0xFF19142a),
        const Color(0xFF3f2b87),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  Widget _buildStars() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Image.asset(
        'assets/stars.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMountains() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Image.asset(
        'assets/mountains_night.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
