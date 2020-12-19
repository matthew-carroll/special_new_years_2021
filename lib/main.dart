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
      body: Landscape(
        mode: EnvironmentMode.night,
        time: '8:45 PM',
        year: '2020',
      ),
    );
  }
}

class Landscape extends StatelessWidget {
  const Landscape({
    Key key,
    this.mode,
    this.time = '',
    this.year = '',
  }) : super(key: key);

  static const switchModeDuration = Duration(milliseconds: 500);
  final EnvironmentMode mode;
  final String time;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSky(),
        _buildStars(),
        _buildMountains(),
        _buildText(),
      ],
    );
  }

  Widget _buildSky() {
    return AnimatedSwitcher(
      duration: switchModeDuration,
      child: DecoratedBox(
        key: ValueKey(mode),
        decoration: BoxDecoration(
          gradient: _buildGradient(),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  LinearGradient _buildGradient() {
    switch (mode) {
      case EnvironmentMode.morning:
        return morningGradient;
      case EnvironmentMode.afternoon:
        return afternoonGradient;
      case EnvironmentMode.evening:
        return eveningGradient;
      case EnvironmentMode.night:
        return nightGradient;
    }
  }

  Widget _buildStars() {
    return mode == EnvironmentMode.night
        ? Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Image.asset(
              'assets/stars.png',
              fit: BoxFit.cover,
            ),
          )
        : SizedBox();
  }

  Widget _buildMountains() {
    String mountainsImagePath = '';
    switch (mode) {
      case EnvironmentMode.morning:
        mountainsImagePath = 'assets/mountains_morning.png';
        break;
      case EnvironmentMode.afternoon:
        mountainsImagePath = 'assets/mountains_afternoon.png';
        break;
      case EnvironmentMode.evening:
        mountainsImagePath = 'assets/mountains_evening.png';
        break;
      case EnvironmentMode.night:
        mountainsImagePath = 'assets/mountains_night.png';
        break;
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSwitcher(
        duration: switchModeDuration,
        child: Image.asset(
          mountainsImagePath,
          key: ValueKey(mode),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildText() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _buildTextColor(),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            year,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _buildTextColor(),
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color _buildTextColor() {
    switch (mode) {
      case EnvironmentMode.morning:
        return morningTextColor;
      case EnvironmentMode.afternoon:
        return afternoonTextColor;
      case EnvironmentMode.evening:
        return eveningTextColor;
      case EnvironmentMode.night:
        return nightTextColor;
    }
  }
}

const morningGradient = LinearGradient(
  colors: [
    const Color(0xFFFAE81C),
    Colors.white,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const morningTextColor = const Color(0xFF797149);

const afternoonGradient = LinearGradient(
  colors: [
    const Color(0xFF0D71F9),
    Colors.white,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const afternoonTextColor = const Color(0xFF5E576C);

const eveningGradient = LinearGradient(
  colors: [
    const Color(0xFFBC3100),
    const Color(0xFFE04F08),
    const Color(0xFFFF8A00),
    const Color(0xFFFFC888),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const eveningTextColor = const Color(0xFF832A2A);

const nightGradient = LinearGradient(
  colors: [
    const Color(0xFF19142a),
    const Color(0xFF3f2b87),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const nightTextColor = const Color(0xFF3C148C);

enum EnvironmentMode {
  morning,
  afternoon,
  evening,
  night,
}
