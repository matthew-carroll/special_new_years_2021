import 'dart:async';
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
        overrideStartDateTime: DateTime.parse('2020-12-31 23:59:49'),
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
        dateTimeBuilder: (DateTime currentTime) {
          return NewYearsCountdownPage(
            currentTime: currentTime,
          );
        },
      ),
    );
  }
}

class TimeLapse extends StatefulWidget {
  const TimeLapse({
    Key key,
    this.overrideStartDateTime,
    this.doTick,
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

      _ticker.stop();
      if (widget.doTick) {
        _ticker.start();
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

  void _onTick(Duration elapsedTime) {
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
    return widget.dateTimeBuilder(_currentTime);
  }
}

class NewYearsCountdownPage extends StatefulWidget {
  const NewYearsCountdownPage({
    Key key,
    @required this.currentTime,
  }) : super(key: key);

  final DateTime currentTime;

  @override
  _NewYearsCountdownPageState createState() => _NewYearsCountdownPageState();
}

class _NewYearsCountdownPageState extends State<NewYearsCountdownPage>
    with SingleTickerProviderStateMixin {
  final DateTime _newYearDateTime = DateTime.parse('2021-01-01 00:00:00');

  final DateFormat _timeFormat = DateFormat('h:mm:ss a');
  final List<ConfettiController> _fireworksControllers = [];
  final List<DateTime> _fireworksStartTimes = [];
  final List<Alignment> _fireworksAlignments = [];
  Timer _generateMoreFireworksTimer;

  AnimationController _mountainFlashController;

  @override
  void initState() {
    super.initState();

    _mountainFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void didUpdateWidget(NewYearsCountdownPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentTime.year != widget.currentTime.year) {
      _doFireworks();
    }
  }

  @override
  void dispose() {
    _generateMoreFireworksTimer?.cancel();

    _mountainFlashController.dispose();

    for (final controller in _fireworksControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _doFireworks() async {
    // Add a new fireworks controller.
    if (_fireworksControllers.length < 25) {
      final newController =
          ConfettiController(duration: const Duration(milliseconds: 1000))
            ..play();
      _fireworksControllers.add(newController);
      _fireworksStartTimes.add(DateTime.now());

      final random = Random();
      final alignHorizontal = (random.nextDouble() * 2.0) - 1.0;
      final alignVertical = (random.nextDouble() * -0.5) - 0.5;
      _fireworksAlignments.add(Alignment(alignHorizontal, alignVertical));

      _mountainFlashController.reverse(from: 1.0);

      if (mounted) {
        final randomTime = Random().nextInt(2000);
        _generateMoreFireworksTimer =
            Timer(Duration(milliseconds: randomTime), () {
          if (mounted) {
            _doFireworks();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final secondsUntilNewYear =
        (_newYearDateTime.difference(widget.currentTime).inMilliseconds / 1000)
            .ceil();

    return Stack(
      children: [
        Landscape(
          mode: _buildEnvironmentMode(),
          fireworks: _buildFireworks(),
          flashPercent: _mountainFlashController.value,
          time: _timeFormat.format(widget.currentTime),
          year: '${widget.currentTime.year}',
        ),
        CountdownText(
          secondsToNewYear: secondsUntilNewYear,
        ),
        HappyNewYearText(
          secondsToNewYear: secondsUntilNewYear,
        ),
      ],
    );
  }

  EnvironmentMode _buildEnvironmentMode() {
    final hour = widget.currentTime.hour;
    if (hour >= 6 && hour < 11) {
      return EnvironmentMode.morning;
    } else if (hour >= 11 && hour < 15) {
      return EnvironmentMode.afternoon;
    } else if (hour >= 15 && hour <= 18) {
      return EnvironmentMode.evening;
    } else {
      return EnvironmentMode.night;
    }
  }

  Widget _buildFireworks() {
    final availableColors = [Colors.blue, Colors.red, Colors.white];
    final colorIndex = Random().nextInt(3);
    final color = availableColors[colorIndex];

    final fireworks = <Widget>[];
    for (var i = 0; i < _fireworksControllers.length; ++i) {
      fireworks.add(
        Align(
          alignment: _fireworksAlignments[i],
          child: ConfettiWidget(
            confettiController: _fireworksControllers[i],
            displayTarget: false,
            blastDirectionality: BlastDirectionality.explosive,
            blastDirection: 2 * pi,
            colors: [color],
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
      );
    }

    return Stack(
      children: fireworks,
    );
  }
}

class CountdownText extends StatefulWidget {
  const CountdownText({
    Key key,
    this.secondsToNewYear,
  }) : super(key: key);

  final int secondsToNewYear;

  @override
  _CountdownTextState createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText>
    with SingleTickerProviderStateMixin {
  AnimationController _showNumberController;
  Interval _opacity = Interval(0.0, 0.4);
  Interval _scale = Interval(0.0, 0.5, curve: Curves.elasticOut);
  int _displayNumber;

  @override
  void initState() {
    super.initState();

    _showNumberController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {});
      });

    _displayNumber = widget.secondsToNewYear;
    if (_isCountingDown()) {
      _showNumberController.forward();
    }
  }

  @override
  void didUpdateWidget(CountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.secondsToNewYear != _displayNumber) {
      _displayNumber = widget.secondsToNewYear;
      if (_isCountingDown()) {
        _showNumberController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _showNumberController.dispose();

    super.dispose();
  }

  bool _isCountingDown() =>
      widget.secondsToNewYear != null &&
      widget.secondsToNewYear <= 9 &&
      widget.secondsToNewYear > 0;

  @override
  Widget build(BuildContext context) {
    if (!_isCountingDown()) {
      return SizedBox();
    }

    return Align(
      alignment: Alignment(0.0, -0.3),
      child: Transform.scale(
        scale: _scale.transform(_showNumberController.value),
        child: Opacity(
          opacity: _opacity.transform(_showNumberController.value),
          child: Text(
            '${widget.secondsToNewYear}',
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
  const HappyNewYearText({
    Key key,
    this.secondsToNewYear,
  }) : super(key: key);

  final secondsToNewYear;

  @override
  _HappyNewYearTextState createState() => _HappyNewYearTextState();
}

class _HappyNewYearTextState extends State<HappyNewYearText>
    with SingleTickerProviderStateMixin {
  AnimationController _showHappyNewYearController;
  Interval _opacity = Interval(0.0, 0.4);
  Interval _scale = Interval(0.0, 0.5, curve: Curves.elasticOut);
  int _previousSecondsToNewYear;

  @override
  void initState() {
    super.initState();

    _showHappyNewYearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        setState(() {});
      });

    _previousSecondsToNewYear = widget.secondsToNewYear;
    if (_shouldDisplayHappyNewYears()) {
      _showHappyNewYearController.forward();
    }
  }

  @override
  void didUpdateWidget(HappyNewYearText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.secondsToNewYear != _previousSecondsToNewYear) {
      _previousSecondsToNewYear = widget.secondsToNewYear;
      if (_shouldDisplayHappyNewYears()) {
        _showHappyNewYearController.forward();
      }
    }
  }

  @override
  void dispose() {
    _showHappyNewYearController.dispose();

    super.dispose();
  }

  bool _shouldDisplayHappyNewYears() =>
      widget.secondsToNewYear != null &&
      widget.secondsToNewYear <= 0 &&
      widget.secondsToNewYear > -35;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _shouldDisplayHappyNewYears()
          ? Align(
              alignment: Alignment(0.0, -0.35),
              child: Transform.scale(
                scale: _scale.transform(_showHappyNewYearController.value),
                child: Opacity(
                  opacity:
                      _opacity.transform(_showHappyNewYearController.value),
                  child: Text(
                    'HAPPY\nNEW\nYEAR',
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
            )
          : null,
    );
  }
}

class Landscape extends StatelessWidget {
  const Landscape({
    Key key,
    this.mode,
    this.fireworks = const SizedBox(),
    this.flashPercent = 0.0,
    this.time = '',
    this.year = '',
  }) : super(key: key);

  static const switchModeDuration = Duration(milliseconds: 500);
  final EnvironmentMode mode;
  final Widget fireworks;
  final double flashPercent;
  final String time;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSky(),
        _buildStars(),
        fireworks,
        _buildMountains(),
        _buildMountainsFlash(),
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

  Widget _buildMountainsFlash() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: flashPercent,
        child: Image.asset(
          'assets/mountains_night_flash.png',
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
