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
      ),
    );
  }
}

class Landscape extends StatelessWidget {
  const Landscape({
    Key key,
    this.mode,
  }) : super(key: key);

  static const switchModeDuration = Duration(milliseconds: 500);
  final EnvironmentMode mode;

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
}

const morningGradient = LinearGradient(
  colors: [
    const Color(0xFFFAE81C),
    Colors.white,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

const afternoonGradient = LinearGradient(
  colors: [
    const Color(0xFF0D71F9),
    Colors.white,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

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

const nightGradient = LinearGradient(
  colors: [
    const Color(0xFF19142a),
    const Color(0xFF3f2b87),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

enum EnvironmentMode {
  morning,
  afternoon,
  evening,
  night,
}
