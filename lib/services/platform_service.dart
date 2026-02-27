import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformService {
  static final PlatformService _instance = PlatformService._internal();
  factory PlatformService() => _instance;
  PlatformService._internal();

  /// Check if running on web
  bool get isWeb => kIsWeb;

  /// Check if running on mobile (Android or iOS)
  bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS);

  /// Check if running on Android
  bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Check if running on iOS
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if running on desktop (Windows, macOS, or Linux)
  bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux);

  /// Check if running on Windows
  bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Check if running on macOS
  bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Check if running on Linux
  bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Get platform name
  String get platformName {
    if (isWeb) return 'Web';
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    return 'Unknown';
  }

  /// Check if platform supports file drag and drop
  bool get supportsDragDrop => isDesktop;

  /// Check if platform supports native menus
  bool get supportsNativeMenus => isDesktop;

  /// Check if platform supports window management
  bool get supportsWindowManagement => isDesktop;

  /// Check if platform supports keyboard shortcuts
  bool get supportsKeyboardShortcuts => isDesktop || isWeb;

  /// Check if platform supports system tray
  bool get supportsSystemTray => isDesktop;

  /// Get appropriate padding for safe areas
  EdgeInsets get safeAreaPadding {
    if (isMobile) {
      // Mobile devices need more padding for notches and gestures
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(8);
  }

  /// Get appropriate app bar height
  double get appBarHeight {
    if (isMobile) return kToolbarHeight;
    if (isDesktop) return 48; // Smaller app bar for desktop
    return kToolbarHeight;
  }

  /// Get grid column count based on screen width and platform
  int getGridColumnCount(double screenWidth) {
    if (isMobile) {
      if (screenWidth < 360) return 2;
      if (screenWidth < 600) return 3;
      return 4;
    }
    if (screenWidth < 800) return 4;
    if (screenWidth < 1200) return 5;
    if (screenWidth < 1600) return 6;
    return 7;
  }

  /// Get appropriate card aspect ratio
  double get bookCardAspectRatio {
    if (isMobile) return 2.0; // Wider cards on mobile for horizontal layout
    return 2.5; // Wider on desktop for horizontal layout
  }

  /// Check if should use cupertino style
  bool get useCupertinoStyle => isIOS;

  /// Get appropriate animation duration
  Duration get animationDuration {
    if (isMobile) return const Duration(milliseconds: 300);
    return const Duration(milliseconds: 200); // Faster on desktop
  }

  /// Get appropriate page transition duration
  Duration get pageTransitionDuration {
    if (isMobile) return const Duration(milliseconds: 400);
    return const Duration(milliseconds: 250);
  }
}
