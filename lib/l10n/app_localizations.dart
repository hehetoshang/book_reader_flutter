import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Universal Reader'**
  String get appTitle;

  /// No description provided for @bookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get bookshelf;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open File'**
  String get openFile;

  /// No description provided for @pdfReader.
  ///
  /// In en, this message translates to:
  /// **'PDF Reader'**
  String get pdfReader;

  /// No description provided for @epubReader.
  ///
  /// In en, this message translates to:
  /// **'EPUB Reader'**
  String get epubReader;

  /// No description provided for @noBooks.
  ///
  /// In en, this message translates to:
  /// **'No books yet'**
  String get noBooks;

  /// No description provided for @addYourFirstBook.
  ///
  /// In en, this message translates to:
  /// **'Add your first book'**
  String get addYourFirstBook;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @readerSettings.
  ///
  /// In en, this message translates to:
  /// **'Reader Settings'**
  String get readerSettings;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @autoSaveProgress.
  ///
  /// In en, this message translates to:
  /// **'Auto Save Progress'**
  String get autoSaveProgress;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared successfully'**
  String get cacheCleared;

  /// No description provided for @clearCookies.
  ///
  /// In en, this message translates to:
  /// **'Clear Cookies'**
  String get clearCookies;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBookConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this book?'**
  String get deleteBookConfirm;

  /// No description provided for @bookDeleted.
  ///
  /// In en, this message translates to:
  /// **'Book deleted successfully'**
  String get bookDeleted;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @fileFormatNotSupported.
  ///
  /// In en, this message translates to:
  /// **'File format not supported'**
  String get fileFormatNotSupported;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @errorOpeningFile.
  ///
  /// In en, this message translates to:
  /// **'Error opening file'**
  String get errorOpeningFile;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About {appName}'**
  String aboutApp(Object appName);

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @bookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// No description provided for @tableOfContents.
  ///
  /// In en, this message translates to:
  /// **'Table of Contents'**
  String get tableOfContents;

  /// No description provided for @readingProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading Progress'**
  String get readingProgress;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @pdfSettings.
  ///
  /// In en, this message translates to:
  /// **'PDF Settings'**
  String get pdfSettings;

  /// No description provided for @epubSettings.
  ///
  /// In en, this message translates to:
  /// **'EPUB Settings'**
  String get epubSettings;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @pdfReaderOptions.
  ///
  /// In en, this message translates to:
  /// **'PDF Reader Options'**
  String get pdfReaderOptions;

  /// No description provided for @epubReaderOptions.
  ///
  /// In en, this message translates to:
  /// **'EPUB Reader Options'**
  String get epubReaderOptions;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dataExportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Data export coming soon'**
  String get dataExportComingSoon;

  /// No description provided for @failedToExportData.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data: {error}'**
  String failedToExportData(Object error);

  /// No description provided for @dataImportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Data import coming soon'**
  String get dataImportComingSoon;

  /// No description provided for @failedToImportData.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data: {error}'**
  String failedToImportData(Object error);

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will delete all books and reading progress. This action cannot be undone.'**
  String get clearAllDataConfirm;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// No description provided for @failedToClearData.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data: {error}'**
  String failedToClearData(Object error);

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get noDescription;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// No description provided for @markAsUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markAsUnread;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @bookInfo.
  ///
  /// In en, this message translates to:
  /// **'Book Info'**
  String get bookInfo;

  /// No description provided for @deleteBook.
  ///
  /// In en, this message translates to:
  /// **'Delete Book'**
  String get deleteBook;

  /// No description provided for @bookInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get bookInfoTitle;

  /// No description provided for @bookInfoAuthor.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get bookInfoAuthor;

  /// No description provided for @bookInfoType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get bookInfoType;

  /// No description provided for @bookInfoAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get bookInfoAdded;

  /// No description provided for @bookInfoLastRead.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get bookInfoLastRead;

  /// No description provided for @bookInfoPages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get bookInfoPages;

  /// No description provided for @bookInfoProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get bookInfoProgress;

  /// No description provided for @bookInfoFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get bookInfoFile;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @opdsCatalogs.
  ///
  /// In en, this message translates to:
  /// **'OPDS Catalogs'**
  String get opdsCatalogs;

  /// No description provided for @noOpdsCatalogs.
  ///
  /// In en, this message translates to:
  /// **'No OPDS Catalogs'**
  String get noOpdsCatalogs;

  /// No description provided for @noOpdsCatalogsDescription.
  ///
  /// In en, this message translates to:
  /// **'Add OPDS catalogs to browse and download online books'**
  String get noOpdsCatalogsDescription;

  /// No description provided for @addOpdsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Add OPDS Catalog'**
  String get addOpdsCatalog;

  /// No description provided for @editOpdsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Edit OPDS Catalog'**
  String get editOpdsCatalog;

  /// No description provided for @deleteOpdsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Delete OPDS Catalog'**
  String get deleteOpdsCatalog;

  /// No description provided for @deleteOpdsCatalogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete catalog \"{title}\"?'**
  String deleteOpdsCatalogConfirm(Object title);

  /// No description provided for @opdsCatalogAdded.
  ///
  /// In en, this message translates to:
  /// **'OPDS catalog added'**
  String get opdsCatalogAdded;

  /// No description provided for @opdsCatalogUpdated.
  ///
  /// In en, this message translates to:
  /// **'OPDS catalog updated'**
  String get opdsCatalogUpdated;

  /// No description provided for @opdsCatalogDeleted.
  ///
  /// In en, this message translates to:
  /// **'OPDS catalog deleted'**
  String get opdsCatalogDeleted;

  /// No description provided for @opdsUrl.
  ///
  /// In en, this message translates to:
  /// **'OPDS Catalog URL'**
  String get opdsUrl;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @connectionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Connection successful'**
  String get connectionSuccessful;

  /// No description provided for @failedToLoadOpdsCatalog.
  ///
  /// In en, this message translates to:
  /// **'Failed to load OPDS catalog'**
  String get failedToLoadOpdsCatalog;

  /// No description provided for @noBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No books found'**
  String get noBooksFound;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @bookDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Book downloaded successfully'**
  String get bookDownloadedSuccessfully;

  /// No description provided for @failedToDownloadBook.
  ///
  /// In en, this message translates to:
  /// **'Failed to download book: {error}'**
  String failedToDownloadBook(Object error);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL format'**
  String get invalidUrl;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noContent.
  ///
  /// In en, this message translates to:
  /// **'No content'**
  String get noContent;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @browseAndDownloadOnlineBooks.
  ///
  /// In en, this message translates to:
  /// **'Browse and download online books'**
  String get browseAndDownloadOnlineBooks;

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authenticationRequired;

  /// No description provided for @authenticationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'This OPDS catalog requires authentication. Please enter your credentials.'**
  String get authenticationRequiredMessage;

  /// No description provided for @errorPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get errorPageNotFound;

  /// No description provided for @errorPageNotFoundSuggestion.
  ///
  /// In en, this message translates to:
  /// **'The requested page could not be found. Please check the URL.'**
  String get errorPageNotFoundSuggestion;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server Error ({statusCode})'**
  String errorServer(Object statusCode);

  /// No description provided for @errorServerSuggestion.
  ///
  /// In en, this message translates to:
  /// **'The server encountered an internal error. Please try again later.'**
  String get errorServerSuggestion;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed ({statusCode})'**
  String errorAuthFailed(Object statusCode);

  /// No description provided for @errorAuthFailedSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please check your credentials.'**
  String get errorAuthFailedSuggestion;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network Connection Failed'**
  String get errorNetwork;

  /// No description provided for @errorNetworkSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection and try again.'**
  String get errorNetworkSuggestion;

  /// No description provided for @errorLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load Failed'**
  String get errorLoadFailed;

  /// No description provided for @errorLoadFailedSuggestion.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. You can try again.'**
  String get errorLoadFailedSuggestion;

  /// No description provided for @importBooks.
  ///
  /// In en, this message translates to:
  /// **'Import Books'**
  String get importBooks;

  /// No description provided for @importFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import from File'**
  String get importFromFile;

  /// No description provided for @importFromFileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select files from your device'**
  String get importFromFileSubtitle;

  /// No description provided for @importFromOpds.
  ///
  /// In en, this message translates to:
  /// **'Import from OPDS'**
  String get importFromOpds;

  /// No description provided for @importFromOpdsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse online book catalogs'**
  String get importFromOpdsSubtitle;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @catalogDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get catalogDescription;

  /// No description provided for @catalogDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get catalogDescriptionHint;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get connectionFailed;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save Password'**
  String get savePassword;

  /// No description provided for @savePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save credentials for future access'**
  String get savePasswordSubtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
