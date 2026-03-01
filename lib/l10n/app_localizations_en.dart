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

  @override
  String get importBooks => 'Import Books';

  @override
  String get importFromFile => 'Import from File';

  @override
  String get importFromFileSubtitle => 'Select PDF or EPUB files from your device';

  @override
  String get importFromOpds => 'Import from OPDS';

  @override
  String get importFromOpdsSubtitle => 'Browse and download books from online OPDS catalogs';

  @override
  String get opdsCatalogs => 'OPDS Catalogs';

  @override
  String get addCatalog => 'Add Catalog';

  @override
  String get editCatalog => 'Edit Catalog';

  @override
  String get deleteCatalog => 'Delete Catalog';

  @override
  String get catalogUrl => 'Catalog URL';

  @override
  String get catalogTitle => 'Catalog Title';

  @override
  String get catalogDescription => 'Catalog Description';

  @override
  String get catalogDescriptionHint => 'Optional: Describe this OPDS catalog';

  @override
  String get catalogUrlHint => 'Enter OPDS catalog Atom feed URL';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get connectionSuccessful => 'Connection Successful';

  @override
  String get connectionFailed => 'Connection Failed';

  @override
  String get downloading => 'Downloading...';

  @override
  String get downloadComplete => 'Download Complete';

  @override
  String get downloadFailed => 'Download Failed';

  @override
  String get cancelDownload => 'Cancel Download';

  @override
  String get bookDetails => 'Book Details';

  @override
  String get download => 'Download';

  @override
  String get publisher => 'Publisher';

  @override
  String get published => 'Published';

  @override
  String failedToLoadOpdsCatalog(Object error) => 'Failed to load OPDS catalog: $error';

  @override
  String get retry => 'Retry';

  @override
  String get noContent => 'No content';

  @override
  String get filters => 'Filters';

  @override
  String get noBooksFound => 'No books found';

  @override
  String get bookDownloadedSuccessfully => 'Book downloaded successfully';

  @override
  String failedToDownloadBook(Object error) => 'Failed to download book: $error';

  @override
  String get summary => 'Summary';

  @override
  String get noOpdsCatalogs => 'No OPDS catalogs';

  @override
  String get noOpdsCatalogsDescription => 'Add an OPDS catalog to browse and download books online';

  @override
  String get addOpdsCatalog => 'Add OPDS Catalog';

  @override
  String get deleteOpdsCatalog => 'Delete Catalog';

  @override
  String deleteOpdsCatalogConfirm(String title) => 'Are you sure you want to delete "$title"?';

  @override
  String get opdsCatalogDeleted => 'OPDS catalog deleted';

  @override
  String get library => 'Library';

  @override
  String get disabled => 'Disabled';

  @override
  String get edit => 'Edit';

  @override
  String get disable => 'Disable';

  @override
  String get enable => 'Enable';

  @override
  String get opdsCatalogUpdated => 'OPDS catalog updated';

  @override
  String get opdsCatalogAdded => 'OPDS catalog added';

  @override
  String get editOpdsCatalog => 'Edit OPDS Catalog';

  @override
  String get opdsUrl => 'OPDS URL';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get title => 'Title';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get browseAndDownloadOnlineBooks => 'Browse and download online books';

  @override
  String get errorPageNotFound => 'Page Not Found (404)';

  @override
  String get errorPageNotFoundSuggestion => 'The requested catalog page does not exist. Please check the URL.';

  @override
  String errorServer(String statusCode) => 'Server Error ($statusCode)';

  @override
  String get errorServerSuggestion => 'The server encountered an internal error. Please try again later.';

  @override
  String errorAuthFailed(String statusCode) => 'Authentication Failed ($statusCode)';

  @override
  String get errorAuthFailedSuggestion => 'Authentication required. Please check your credentials in settings.';

  @override
  String get errorNetwork => 'Network Connection Failed';

  @override
  String get errorNetworkSuggestion => 'Please check your network connection and try again.';

  @override
  String get errorLoadFailed => 'Load Failed';

  @override
  String get errorLoadFailedSuggestion => 'An unknown error occurred. You can try again.';
}
