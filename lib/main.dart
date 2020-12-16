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
      home: NewYearsCountdown(
        overrideStartDateTime: DateTime.parse('2020-12-31 23:59:49'),
        // overrideStartDateTime: DateTime.parse('2021-01-01 00:00:00'),
        doTick: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NewYearsCountdown extends StatefulWidget {
  const NewYearsCountdown({
    Key key,
    this.overrideStartDateTime,
    this.doTick = true,
  }) : super(key: key);

  final DateTime overrideStartDateTime;
  final bool doTick;

  @override
  _NewYearsCountdownState createState() => _NewYearsCountdownState();
}

class _NewYearsCountdownState extends State<NewYearsCountdown>
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
  void didUpdateWidget(NewYearsCountdown oldWidget) {
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
    return NewYearsCelebration(
      now: _currentTime,
    );
  }
}

class NewYearsCelebration extends StatefulWidget {
  const NewYearsCelebration({
    Key key,
    @required this.now,
  }) : super(key: key);

  final DateTime now;

  @override
  _NewYearsCelebrationState createState() => _NewYearsCelebrationState();
}

class _NewYearsCelebrationState extends State<NewYearsCelebration>
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
  void didUpdateWidget(NewYearsCelebration oldWidget) {
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
      backgroundColor: Colors.red,
      body: Stack(
        children: [
          Landscape(
            mode: _environmentMode,
            flashPercent: _mountainFlashController.value,
            fireworks: _buildFireworks(),
            time: _timeFormat.format(widget.now),
            year: '${widget.now.year}',
          ),
          Countdown(
            number: secondsUntilNewYear > 0 && secondsUntilNewYear <= 10
                ? secondsUntilNewYear
                : null,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: secondsUntilNewYear <= 0 && secondsUntilNewYear > -60
                ? HappyNewYear()
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

class Countdown extends StatefulWidget {
  const Countdown({Key key, this.number}) : super(key: key);

  final int number;

  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown>
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
  void didUpdateWidget(Countdown oldWidget) {
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

class HappyNewYear extends StatefulWidget {
  @override
  _HappyNewYearState createState() => _HappyNewYearState();
}

class _HappyNewYearState extends State<HappyNewYear>
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
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(widget.mode),
            decoration: BoxDecoration(
              gradient: _buildGradient(),
            ),
          ),
        ),
        if (widget.mode == EnvironmentMode.night)
          Positioned(
            left: 0,
            right: 0,
            top: -50,
            child: Image.asset(
              'assets/stars.png',
              fit: BoxFit.cover,
            ),
          ),
        widget.fireworks,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildMountains(),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Opacity(
            opacity: widget.flashPercent,
            child: _buildMountainsFlash(),
          ),
        ),
        Positioned(
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
        ),
      ],
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

  Widget _buildMountainsFlash() {
    return Image.asset(
      'assets/mountains_night_flash.png',
      fit: BoxFit.cover,
    );
  }

  Widget _buildMountains() {
    switch (widget.mode) {
      case EnvironmentMode.morning:
        return Image.asset(
          'assets/mountains_morning.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
      case EnvironmentMode.afternoon:
        return Image.asset(
          'assets/mountains_afternoon.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
      case EnvironmentMode.evening:
        return Image.asset(
          'assets/mountains_evening.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
      case EnvironmentMode.night:
        return Image.asset(
          'assets/mountains_night.png',
          key: ValueKey(widget.mode),
          fit: BoxFit.cover,
        );
    }
  }
}

enum EnvironmentMode {
  morning,
  afternoon,
  evening,
  night,
}
