import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
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

/// Whole screen display of a new years countdown and celebration.
class NewYearsCountdownScreen extends StatelessWidget {
  const NewYearsCountdownScreen({
    Key key,
    this.overrideStartDateTime,
    this.doTick = true,
  }) : super(key: key);

  final DateTime overrideStartDateTime;
  final bool doTick;

  @override
  Widget build(BuildContext context) {
    return TimeLapse(
      overrideStartDateTime: overrideStartDateTime,
      doTick: doTick,
      dateTimeBuilder: (currentTime) {
        return NewYearsCountdownPage(
          now: currentTime,
        );
      },
    );
  }
}

/// Reports a date/time as time changes.
///
/// A custom initial time can be provided via `overrideStartDateTime`. The
/// system's current date/time are used if no override is provided.
///
/// Time reporting can be limited to just a single tick, without changing
/// over time, by setting `doTick` to `false`.
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

/// Display of a new years countdown and celebration based on the given
/// `DateTime` in `now`.
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
  final DateFormat _timeFormat = DateFormat('h:mm:ss a');
  final DateTime _newYearDateTime = DateTime.parse('2021-01-01 00:00:00');

  final List<ConfettiController> _confettiControllers = [];
  final List<DateTime> _confettiStartTimes = [];
  final List<Alignment> _confettiAlignments = [];
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

    if (oldWidget.now.year != widget.now.year) {
      _doFireworks();
    }
  }

  @override
  void dispose() {
    _generateMoreFireworksTimer?.cancel();

    for (final controller in _confettiControllers) {
      controller.dispose();
    }

    _mountainFlashController.dispose();

    super.dispose();
  }

  Future<void> _doFireworks() async {
    bool hasRemainingFireworksToStop = false;

    // Stop confetti controllers that have already had time for their
    // first emission.
    for (var i = 0; i < _confettiControllers.length; ++i) {
      if (DateTime.now().second - _confettiStartTimes[i].second > 1) {
        _confettiControllers[i].stop();
      } else {
        hasRemainingFireworksToStop = true;
      }
    }

    // Add a new controller.
    if (_confettiControllers.length < 25) {
      setState(() {
        final newController =
            ConfettiController(duration: const Duration(seconds: 10))..play();
        _confettiControllers.add(newController);
        _confettiStartTimes.add(DateTime.now());

        final random = Random();
        final alignHorizontal = (random.nextDouble() * 2.0) - 1.0;
        final alignVertical = (random.nextDouble() * -0.5) - 0.5;
        _confettiAlignments.add(Alignment(alignHorizontal, alignVertical));
      });

      _mountainFlashController.reverse(from: 1.0);

      // Run again after random time.
      if (mounted) {
        final randomTime = Random().nextInt(2000);
        _generateMoreFireworksTimer =
            Timer(Duration(milliseconds: randomTime), () {
          if (mounted) {
            _doFireworks();
          }
        });
      }
    } else if (hasRemainingFireworksToStop) {
      if (mounted) {
        _generateMoreFireworksTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) {
            _doFireworks();
          }
        });
      }
    }
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
            flashPercent: _mountainFlashController.value,
            fireworks: _buildFireworks(),
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

  Widget _buildFireworks() {
    final random = Random();
    final colors = [Colors.blue, Colors.red, Colors.white];
    final colorIndex = random.nextInt(3);
    final color = colors[colorIndex];

    final fireworks = <Widget>[];
    for (var i = 0; i < _confettiControllers.length; ++i) {
      final controller = _confettiControllers[i];
      fireworks.add(
        Align(
          alignment: _confettiAlignments[i],
          child: ConfettiWidget(
            confettiController: controller,
            // displayTarget: true,
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

/// Displays a large countdown number near the center of the available
/// space/screen.
class CountdownText extends StatefulWidget {
  const CountdownText({Key key, this.number}) : super(key: key);

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

/// Displays "Happy New Year" in large text near the center of the available
/// space/screen.
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

/// Presents a background sky, mid-ground mountains, foreground time/date,
/// and optionally some `fireworks` behind the mountains.
class Landscape extends StatefulWidget {
  Landscape({
    Key key,
    @required this.mode,
    this.fireworks = const SizedBox(),
    this.flashPercent = 0.0,
    @required this.time,
    @required this.year,
  }) : super(key: key);

  final EnvironmentMode mode;
  final Widget fireworks;
  final double flashPercent;
  final String time;
  final String year;

  @override
  _LandscapeState createState() => _LandscapeState();
}

class _LandscapeState extends State<Landscape> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildSky(),
        if (widget.mode == EnvironmentMode.night) _buildStars(),
        widget.fireworks,
        _buildMountains(),
        _buildMountainsFlash(),
        _buildText(),
      ],
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
            widget.time,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textColor,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            widget.year,
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
    switch (widget.mode) {
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

  Widget _buildSky() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: DecoratedBox(
        key: ValueKey(widget.mode),
        decoration: BoxDecoration(
          gradient: _buildGradient(),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  Gradient _buildGradient() {
    switch (widget.mode) {
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

  Widget _buildMountainsFlash() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Opacity(
        opacity: widget.flashPercent,
        child: Image.asset(
          'assets/mountains_night_flash.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildMountains() {
    Widget mountainsImage;
    switch (widget.mode) {
      case EnvironmentMode.morning:
        mountainsImage = Image.asset(
          'assets/mountains_morning.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
        break;
      case EnvironmentMode.afternoon:
        mountainsImage = Image.asset(
          'assets/mountains_afternoon.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
        break;
      case EnvironmentMode.evening:
        mountainsImage = Image.asset(
          'assets/mountains_evening.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
        break;
      case EnvironmentMode.night:
        mountainsImage = Image.asset(
          'assets/mountains_night.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
        break;
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: mountainsImage,
      ),
    );
  }
}

enum EnvironmentMode {
  morning,
  afternoon,
  evening,
  night,
}
