import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Universal Reader';
  static const String appDescription = '一款支持 PDF 和 EPUB 的跨平台阅读器';

  // Organization
  static const String organizationDomain = 'com.houheya.reader';

  // Storage Keys
  static const String booksBoxName = 'books';
  static const String progressBoxName = 'reading_progress';
  static const String settingsBoxName = 'app_settings';

  // Supported File Types
  static const List<String> supportedExtensions = ['pdf', 'epub'];
  static const List<String> pdfExtensions = ['pdf'];
  static const List<String> epubExtensions = ['epub'];

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 8.0;
  static const double smallBorderRadius = 4.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Reading Settings
  static const double minFontSize = 8.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 16.0;
  static const double fontSizeStep = 2.0;

  static const double minLineHeight = 1.0;
  static const double maxLineHeight = 3.0;
  static const double defaultLineHeight = 1.5;
  static const double lineHeightStep = 0.1;

  static const double minLetterSpacing = -2.0;
  static const double maxLetterSpacing = 5.0;
  static const double defaultLetterSpacing = 0.0;
  static const double letterSpacingStep = 0.5;

  // PDF Settings
  static const double minZoom = 0.25;
  static const double maxZoom = 5.0;
  static const double defaultZoom = 1.0;
  static const double zoomStep = 0.25;

  // Grid Layout
  static const int mobileGridColumns = 3;
  static const int tabletGridColumns = 4;
  static const int desktopGridColumns = 6;

  static const double bookCardAspectRatio = 0.7;
  static const double bookCardBorderRadius = 8.0;

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Accent Colors
  static const Color accent = Color(0xFFFF4081);
  static const Color accentDark = Color(0xFFF50057);
  static const Color accentLight = Color(0xFFFF80AB);

  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // EPUB Theme Colors
  static const Color epubLightBackground = Color(0xFFFFFFFF);
  static const Color epubLightText = Color(0xFF000000);

  static const Color epubDarkBackground = Color(0xFF1A1A1A);
  static const Color epubDarkText = Color(0xFFE0E0E0);

  static const Color epubSepiaBackground = Color(0xFFF4ECD8);
  static const Color epubSepiaText = Color(0xFF5B4636);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        background: AppColors.backgroundLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onBackground: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        filled: true,
        fillColor: AppColors.surfaceLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding * 2,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        background: AppColors.backgroundDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        filled: true,
        fillColor: AppColors.surfaceDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding * 2,
            vertical: AppConstants.defaultPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
        ),
      ),
    );
  }
}

class AppStrings {
  // General
  static const String appName = 'Universal Reader';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String save = 'Save';
  static const String close = 'Close';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';

  // Shelf
  static const String shelfTitle = 'My Books';
  static const String emptyShelf = 'No books yet';
  static const String emptyShelfSubtitle = 'Import books to get started';
  static const String importBooks = 'Import Books';
  static const String searchBooks = 'Search books...';
  static const String favorites = 'Favorites';
  static const String recentlyRead = 'Recently Read';

  // Book Actions
  static const String open = 'Open';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String markAsRead = 'Mark as Read';
  static const String markAsUnread = 'Mark as Unread';
  static const String bookInfo = 'Book Info';
  static const String deleteBook = 'Delete Book';
  static const String deleteBookConfirm =
      'Are you sure you want to delete this book?';

  // Reader
  static const String tableOfContents = 'Table of Contents';
  static const String bookmarks = 'Bookmarks';
  static const String notes = 'Notes';
  static const String search = 'Search';
  static const String settings = 'Settings';
  static const String addBookmark = 'Add Bookmark';
  static const String addNote = 'Add Note';
  static const String editNote = 'Edit Note';
  static const String deleteNote = 'Delete Note';

  // PDF Reader
  static const String pageOf = 'Page %d of %d';
  static const String zoom = 'Zoom';
  static const String fitWidth = 'Fit Width';
  static const String fitPage = 'Fit Page';
  static const String rotate = 'Rotate';

  // EPUB Reader
  static const String fontSize = 'Font Size';
  static const String lineHeight = 'Line Height';
  static const String letterSpacing = 'Letter Spacing';
  static const String textAlign = 'Text Alignment';
  static const String theme = 'Theme';
  static const String light = 'Light';
  static const String dark = 'Dark';
  static const String sepia = 'Sepia';
  static const String fontFamily = 'Font Family';

  // Settings
  static const String appearance = 'Appearance';
  static const String language = 'Language';
  static const String themeMode = 'Theme Mode';
  static const String system = 'System';
  static const String pdfSettings = 'PDF Settings';
  static const String epubSettings = 'EPUB Settings';
  static const String dataManagement = 'Data Management';
  static const String exportData = 'Export Data';
  static const String importData = 'Import Data';
  static const String about = 'About';
  static const String version = 'Version';
  static const String openSourceLicenses = 'Open Source Licenses';

  // Languages
  static const String english = 'English';
  static const String chinese = '中文';
}
