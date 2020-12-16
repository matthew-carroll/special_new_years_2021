import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'package:new_year_2021/main.dart';

Future<void> main() async {
  await loadAppFonts();

  testGoldens('times of day', (tester) async {
    configureToLookLikeIPhone11(tester);

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 08:00:00')),
    );
    await screenMatchesGolden(tester, 'time_of_day_morning');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 12:00:00')),
    );
    await screenMatchesGolden(tester, 'time_of_day_afternoon');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 17:00:00')),
    );
    await screenMatchesGolden(tester, 'time_of_day_evening');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 20:00:00')),
    );
    await screenMatchesGolden(tester, 'time_of_day_night');
  });

  testGoldens('new years countdown', (tester) async {
    configureToLookLikeIPhone11(tester);

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:49')),
    );
    await screenMatchesGolden(tester, '11_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:50')),
    );
    await screenMatchesGolden(tester, '10_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:51')),
    );
    await screenMatchesGolden(tester, '9_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:52')),
    );
    await screenMatchesGolden(tester, '8_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:53')),
    );
    await screenMatchesGolden(tester, '7_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:54')),
    );
    await screenMatchesGolden(tester, '6_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:55')),
    );
    await screenMatchesGolden(tester, '5_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:56')),
    );
    await screenMatchesGolden(tester, '4_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:57')),
    );
    await screenMatchesGolden(tester, '3_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:58')),
    );
    await screenMatchesGolden(tester, '2_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2020-12-31 23:59:59')),
    );
    await screenMatchesGolden(tester, '1_seconds_to_go');

    await tester.pumpWidget(
      _screenForDateTime(DateTime.parse('2021-01-01 00:00:00')),
    );
    await screenMatchesGolden(tester, 'happy_new_year');

    await tester.pumpAndSettle();
  });
}

Widget _screenForDateTime(DateTime dateTime) {
  return MaterialApp(
    home: NewYearsCountdown(
      overrideStartDateTime: dateTime,
      doTick: false,
    ),
    debugShowCheckedModeBanner: false,
  );
}

void configureToLookLikeIPhone11(WidgetTester tester) {
  // Make the test render like an iPhone11 so that it looks normal to us.
  tester.binding.window.physicalSizeTestValue = Device.iphone11.size;
  tester.binding.window.devicePixelRatioTestValue =
      Device.iphone11.devicePixelRatio;
  tester.binding.window.textScaleFactorTestValue = Device.iphone11.textScale;
}
