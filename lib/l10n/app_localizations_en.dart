// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Universal Reader';

  @override
  String get bookshelf => 'Bookshelf';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get openFile => 'Open File';

  @override
  String get pdfReader => 'PDF Reader';

  @override
  String get epubReader => 'EPUB Reader';

  @override
  String get noBooks => 'No books yet';

  @override
  String get addYourFirstBook => 'Add your first book';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get readerSettings => 'Reader Settings';

  @override
  String get fontSize => 'Font Size';

  @override
  String get theme => 'Theme';

  @override
  String get autoSaveProgress => 'Auto Save Progress';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get cacheCleared => 'Cache cleared successfully';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBookConfirm => 'Are you sure you want to delete this book?';

  @override
  String get bookDeleted => 'Book deleted successfully';

  @override
  String get share => 'Share';

  @override
  String get fileFormatNotSupported => 'File format not supported';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get errorOpeningFile => 'Error opening file';

  @override
  String aboutApp(Object appName) {
    return 'About $appName';
  }

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get description => 'A cross-platform reader that supports PDF and EPUB formats';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get search => 'Search';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get tableOfContents => 'Table of Contents';

  @override
  String get readingProgress => 'Reading Progress';

  @override
  String get appearance => 'Appearance';

  @override
  String get pdfSettings => 'PDF Settings';

  @override
  String get epubSettings => 'EPUB Settings';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get pdfReaderOptions => 'PDF Reader Options';

  @override
  String get epubReaderOptions => 'EPUB Reader Options';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get dataExportComingSoon => 'Data export coming soon';

  @override
  String failedToExportData(Object error) {
    return 'Failed to export data: $error';
  }

  @override
  String get dataImportComingSoon => 'Data import coming soon';

  @override
  String failedToImportData(Object error) {
    return 'Failed to import data: $error';
  }

  @override
  String get clearAllDataConfirm => 'This will delete all books and reading progress. This action cannot be undone.';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String failedToClearData(Object error) {
    return 'Failed to clear data: $error';
  }

  @override
  String get noDescription => 'No description';

  @override
  String get unknown => 'Unknown';

  @override
  String get open => 'Open';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get markAsUnread => 'Mark as unread';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get bookInfo => 'Book Info';

  @override
  String get deleteBook => 'Delete Book';

  @override
  String get bookInfoTitle => 'Title';

  @override
  String get bookInfoAuthor => 'Author';

  @override
  String get bookInfoType => 'Type';

  @override
  String get bookInfoAdded => 'Added';

  @override
  String get bookInfoLastRead => 'Last Read';

  @override
  String get bookInfoPages => 'Pages';

  @override
  String get bookInfoProgress => 'Progress';

  @override
  String get bookInfoFile => 'File';

  @override
  String get close => 'Close';
}
