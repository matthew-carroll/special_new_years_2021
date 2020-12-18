import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

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
      home: NewYearsCountdownScreen(
        overrideStartDateTime: DateTime.parse('2020-12-31 20:59:49'),
        doTick: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewYearsCountdownScreen extends StatelessWidget {
  NewYearsCountdownScreen({
    Key key,
    this.overrideStartDateTime,
    this.doTick,
  }) : super(key: key);

  final DateTime overrideStartDateTime;
  final bool doTick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimeLapse(
        overrideStartDateTime: overrideStartDateTime,
        doTick: doTick,
        dateTimeBuilder: (currentTime) {
          return NewYearsCountdownPage(now: currentTime);
        },
      ),
    );
  }
}

class TimeLapse extends StatefulWidget {
  const TimeLapse({
    Key key,
    this.overrideStartDateTime,
    this.doTick = true,
    this.dateTimeBuilder,
  }) : super(key: key);

  final DateTime overrideStartDateTime;
  final bool doTick;
  final Widget Function(DateTime) dateTimeBuilder;

  @override
  _TimeLapseState createState() => _TimeLapseState();
}

class _TimeLapseState extends State<TimeLapse>
    with SingleTickerProviderStateMixin {
  Ticker _ticker;
  DateTime _initialTime;
  DateTime _currentTime;

  @override
  void initState() {
    super.initState();

    if (widget.overrideStartDateTime != null) {
      _initialTime = widget.overrideStartDateTime;
    } else {
      _initialTime = DateTime.now();
    }
    _currentTime = _initialTime;

    _ticker = createTicker(_onTick);
    if (widget.doTick) {
      _ticker.start();
    }
  }

  @override
  void didUpdateWidget(TimeLapse oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.overrideStartDateTime != oldWidget.overrideStartDateTime) {
      if (widget.overrideStartDateTime == null) {
        _initialTime = DateTime.now();
      } else {
        _initialTime = widget.overrideStartDateTime;
      }

      _currentTime = _initialTime;
      if (widget.doTick) {
        _ticker
          ..stop()
          ..start();
      }
    } else if (widget.doTick != oldWidget.doTick) {
      if (widget.doTick) {
        _ticker.start();
      } else {
        _ticker.stop();
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(elapsedTime) {
    if (_initialTime == null) {
      _initialTime = DateTime.now();
    }

    final newTime = _initialTime.add(elapsedTime);
    if (newTime.second != _currentTime.second) {
      setState(() {
        _currentTime = newTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dateTimeBuilder != null) {
      return widget.dateTimeBuilder(_currentTime);
    } else {
      return SizedBox();
    }
  }
}

class NewYearsCountdownPage extends StatefulWidget {
  const NewYearsCountdownPage({
    Key key,
    @required this.now,
  }) : super(key: key);

  final DateTime now;

  @override
  _NewYearsCountdownPageState createState() => _NewYearsCountdownPageState();
}

class _NewYearsCountdownPageState extends State<NewYearsCountdownPage>
    with TickerProviderStateMixin {
  final DateTime _newYearDateTime = DateTime.parse('2021-01-01 00:00:00');

  final DateFormat _timeFormat = DateFormat('h:mm:ss a');

  ConfettiController _fireworksController;

  @override
  void initState() {
    super.initState();

    _fireworksController =
        ConfettiController(duration: const Duration(seconds: 1))..play();
  }

  @override
  Widget build(BuildContext context) {
    // We ceil() the fraction so that when time hits something like 23:59:59.007
    // we treat that as 10 seconds instead of 9 seconds.
    final secondsUntilNewYear =
        (_newYearDateTime.difference(widget.now).inMilliseconds / 1000).ceil();

    return Scaffold(
      body: Stack(
        children: [
          Landscape(
            mode: _environmentMode,
            fireworks: Align(
              alignment: Alignment(0.0, -0.5),
              child: ConfettiWidget(
                confettiController: _fireworksController,
                displayTarget: true,
                blastDirectionality: BlastDirectionality.explosive,
                blastDirection: 2 * pi,
                colors: [Colors.red],
                minimumSize: Size(1, 1),
                maximumSize: Size(5, 5),
                minBlastForce: 0.001,
                maxBlastForce: 0.0011,
                gravity: 0.1,
                particleDrag: 0.1,
                numberOfParticles: 35,
                emissionFrequency: 0.00000001,
                shouldLoop: false,
              ),
            ),
            time: _timeFormat.format(widget.now),
            year: '${widget.now.year}',
          ),
          CountdownText(
            number: secondsUntilNewYear > 0 && secondsUntilNewYear <= 10
                ? secondsUntilNewYear
                : null,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: secondsUntilNewYear <= 0 && secondsUntilNewYear > -35
                ? HappyNewYearText()
                : null,
          ),
        ],
      ),
    );
  }

  EnvironmentMode get _environmentMode {
    if (widget.now.hour >= 6 && widget.now.hour < 11) {
      return EnvironmentMode.morning;
    } else if (widget.now.hour >= 11 && widget.now.hour < 15) {
      return EnvironmentMode.afternoon;
    } else if (widget.now.hour >= 15 && widget.now.hour <= 18) {
      return EnvironmentMode.evening;
    } else {
      return EnvironmentMode.night;
    }
  }
}

class CountdownText extends StatefulWidget {
  const CountdownText({
    Key key,
    this.number,
  }) : super(key: key);

  final int number;

  @override
  _CountdownTextState createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText>
    with SingleTickerProviderStateMixin {
  AnimationController _showNumberController;
  Interval _opacity = Interval(0.0, 0.4);
  Interval _scale = Interval(0.0, 0.5, curve: Curves.elasticOut);
  int _displayedNumber;

  @override
  void initState() {
    super.initState();

    _showNumberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {});
      });

    _displayedNumber = widget.number;
    if (_displayedNumber != null) {
      _showNumberController.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.number != _displayedNumber) {
      _displayedNumber = widget.number;
      _showNumberController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _showNumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.number == null) {
      return SizedBox();
    }

    return Align(
      alignment: Alignment(0.0, -0.3),
      child: Transform.scale(
        scale: _scale.transform(_showNumberController.value),
        alignment: Alignment.center,
        child: Opacity(
          opacity: _opacity.transform(_showNumberController.value),
          child: Text(
            '$_displayedNumber',
            style: TextStyle(
              color: Colors.white,
              fontSize: 240,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class HappyNewYearText extends StatefulWidget {
  @override
  _HappyNewYearTextState createState() => _HappyNewYearTextState();
}

class _HappyNewYearTextState extends State<HappyNewYearText>
    with SingleTickerProviderStateMixin {
  AnimationController _showHappyNewYearController;
  Interval _opacity = Interval(0.0, 0.4);
  Interval _scale = Interval(0.0, 0.5, curve: Curves.elasticOut);

  @override
  void initState() {
    super.initState();

    _showHappyNewYearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )
      ..addListener(() {
        setState(() {});
      })
      ..forward(from: 0.0);
  }

  @override
  void dispose() {
    _showHappyNewYearController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0.0, -0.35),
      child: Transform.scale(
        scale: _scale.transform(_showHappyNewYearController.value),
        child: Opacity(
          opacity: _opacity.transform(_showHappyNewYearController.value),
          child: Text(
            'HAPPY\nNEW\nYEAR!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
              fontWeight: FontWeight.bold,
              height: 0.9,
            ),
          ),
        ),
      ),
    );
  }
}

class Landscape extends StatelessWidget {
  Landscape({
    Key key,
    @required this.mode,
    this.fireworks = const SizedBox(),
    this.time = '',
    this.year = '',
  }) : super(key: key);

  static const switchModeDuration = Duration(milliseconds: 500);
  final EnvironmentMode mode;
  final Widget fireworks;
  final String time;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSky(),
        if (mode == EnvironmentMode.night) _buildStars(),
        fireworks,
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

  Gradient _buildGradient() {
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
    return Positioned(
      left: 0,
      right: 0,
      top: -50,
      child: Image.asset(
        'assets/stars.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMountains() {
    String mountainsImagePath;
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
      bottom: 16,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            year,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Color get _textColor {
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
    const Color(0xFFfae81c),
    const Color(0xFFFFFFFF),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const morningTextColor = const Color(0xFF797149);

const afternoonGradient = LinearGradient(
  colors: [
    const Color(0xFF0d71f9),
    const Color(0xFFFFFFFF),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const afternoonTextColor = const Color(0xFF5e576c);

const eveningGradient = LinearGradient(
  colors: [
    const Color(0xFFbc3100),
    const Color(0xFFe04f08),
    const Color(0xFFff8a00),
    const Color(0xFFffc888),
  ],
  stops: [
    0.14,
    0.44,
    0.62,
    0.77,
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const eveningTextColor = const Color(0xFF832a2a);

const nightGradient = LinearGradient(
  colors: [
    const Color(0xFF19142a),
    const Color(0xFF3f2b87),
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const nightTextColor = const Color(0xFF3c148c);

enum EnvironmentMode {
  morning,
  afternoon,
  evening,
  night,
}
