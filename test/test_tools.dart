import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void configureToLookLikeIPhone11(WidgetTester tester) {
  // Make the test render like an iPhone11 so that it looks normal to us.
  tester.binding.window.physicalSizeTestValue = Device.iphone11.size;
  tester.binding.window.devicePixelRatioTestValue =
      Device.iphone11.devicePixelRatio;
  tester.binding.window.textScaleFactorTestValue = Device.iphone11.textScale;
}
