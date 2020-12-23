import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void configureToLookLikeIPhone11(WidgetTester tester) {
  tester.binding.window
    ..physicalSizeTestValue = Device.iphone11.size
    ..devicePixelRatioTestValue = Device.iphone11.devicePixelRatio
    ..textScaleFactorTestValue = Device.iphone11.textScale;
}
