import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:katbook_epub_reader/katbook_epub_reader.dart' as epub_reader;
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'models/models.dart';
import 'providers/providers.dart';
import 'routes/app_router.dart';
import 'services/services.dart';
import 'utils/utils.dart';

class UniversalReaderApp extends StatefulWidget {
  const UniversalReaderApp({super.key});

  @override
  State<UniversalReaderApp> createState() => _UniversalReaderAppState();
}

class _UniversalReaderAppState extends State<UniversalReaderApp> {
  bool _isLoading = true;
  String? _error;
  late final SettingsProvider _settingsProvider;
  late final BookProvider _bookProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _settingsProvider = context.read<SettingsProvider>();
      _bookProvider = context.read<BookProvider>();
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize storage service
      await StorageService().initialize();

      // Load settings
      await _settingsProvider.loadSettings();

      // Load books
      await _bookProvider.loadBooks();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Loading ${AppConstants.appName}...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to initialize app'),
                const SizedBox(height: 8),
                Text(_error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _error = null;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: _getThemeMode(settings.themeMode),

          // Localization - 包含项目和 EPUB 阅读器的本地化委托
          localizationsDelegates: const [
            AppLocalizations.delegate,
            epub_reader.AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
            Locale('fr'),
          ],
          locale: settings.locale ?? WidgetsBinding.instance.platformDispatcher.locale,

          // Router
          routerConfig: AppRouter.router,
        );
      },
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class UniversalReaderAppWrapper extends StatelessWidget {
  const UniversalReaderAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ReadingProvider()),
        ChangeNotifierProvider(create: (_) => OpdsProvider()),
      ],
      child: const UniversalReaderApp(),
    );
  }
}
