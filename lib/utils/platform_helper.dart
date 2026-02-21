import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for platform-specific functionality
class PlatformHelper {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if running on mobile platform (Android or iOS)
  static bool get isMobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS);

  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// Check if running on desktop platform
  static bool get isDesktop => !kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux);

  /// Check if running on Windows
  static bool get isWindows => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  /// Check if running on macOS
  static bool get isMacOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

  /// Check if running on Linux
  static bool get isLinux => !kIsWeb && defaultTargetPlatform == TargetPlatform.linux;

  /// Get platform-specific back button icon
  static IconData get backButtonIcon {
    if (isIOS) return Icons.arrow_back_ios;
    return Icons.arrow_back;
  }

  /// Get platform-specific menu button icon
  static IconData get menuButtonIcon {
    if (isIOS) return Icons.more_horiz;
    return Icons.more_vert;
  }

  /// Get platform-specific settings icon
  static IconData get settingsIcon {
    if (isIOS) return Icons.settings_applications;
    return Icons.settings;
  }

  /// Get appropriate page transition
  static PageTransitionsBuilder get pageTransitions {
    if (isIOS) {
      return const CupertinoPageTransitionsBuilder();
    }
    return const FadeUpwardsPageTransitionsBuilder();
  }

  /// Set system UI overlay style based on platform
  static void setSystemUIOverlayStyle(Brightness brightness) {
    if (isMobile) {
      final style = brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark;
      SystemChrome.setSystemUIOverlayStyle(style);
    }
  }

  /// Enable fullscreen mode
  static void enableFullscreen() {
    if (isMobile) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.immersiveSticky,
        overlays: [],
      );
    }
  }

  /// Disable fullscreen mode
  static void disableFullscreen() {
    if (isMobile) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      );
    }
  }

  /// Set preferred orientations
  static void setPreferredOrientations(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  /// Allow all orientations
  static void allowAllOrientations() {
    setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Lock to portrait orientation
  static void lockPortrait() {
    setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Lock to landscape orientation
  static void lockLandscape() {
    setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

/// Widget that adapts to the platform
class PlatformAdaptiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const PlatformAdaptiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isWeb && web != null) {
      return web!;
    }

    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1200 && desktop != null) {
      return desktop!;
    }
    
    if (width >= 600 && tablet != null) {
      return tablet!;
    }
    
    return mobile;
  }
}

/// Platform-specific padding
class PlatformPadding {
  static EdgeInsets get screenPadding {
    if (PlatformHelper.isMobile) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(24);
  }

  static EdgeInsets get cardPadding {
    if (PlatformHelper.isMobile) {
      return const EdgeInsets.all(12);
    }
    return const EdgeInsets.all(16);
  }

  static EdgeInsets get listPadding {
    if (PlatformHelper.isMobile) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  }
}

/// Platform-specific sizes
class PlatformSize {
  static double get iconSize {
    if (PlatformHelper.isMobile) return 24;
    return 28;
  }

  static double get appBarHeight {
    if (PlatformHelper.isMobile) return kToolbarHeight;
    return 56;
  }

  static double get buttonHeight {
    if (PlatformHelper.isMobile) return 44;
    return 48;
  }

  static double get touchTarget {
    if (PlatformHelper.isMobile) return 44;
    return 40;
  }
}
