import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  tabletSmall,
  tabletLarge;

  bool get isTablet => this == tabletSmall || this == tabletLarge;
}

class Breakpoints {
  static const double phoneMax = 600.0;
  static const double tabletSmallMax = 960.0;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < phoneMax) {
      return DeviceType.phone;
    } else if (width < tabletSmallMax) {
      return DeviceType.tabletSmall;
    } else {
      return DeviceType.tabletLarge;
    }
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= phoneMax;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }
}
