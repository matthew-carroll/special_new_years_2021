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

  final DateFormat _timeFormat = DateFormat('h:mm:ss a');

  final DateTime overrideStartDateTime;
  final bool doTick;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TimeLapse(
        overrideStartDateTime: overrideStartDateTime,
        doTick: doTick,
        dateTimeBuilder: (currentTime) {
          return Landscape(
            mode: EnvironmentMode.night,
            time: _timeFormat.format(currentTime),
            year: '${currentTime.year}',
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

class Landscape extends StatelessWidget {
  Landscape({
    Key key,
    @required this.mode,
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
        if (mode == EnvironmentMode.night) _buildStars(),
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
