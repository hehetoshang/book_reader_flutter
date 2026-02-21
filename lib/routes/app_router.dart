import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../screens/screens.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Shelf (Home) Route
      GoRoute(
        path: '/',
        name: 'shelf',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ShelfScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      ),

      // PDF Reader Route
      GoRoute(
        path: '/pdf/:bookId',
        name: 'pdf_reader',
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: PdfReaderScreen(bookId: bookId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return MaterialPageRoute(
                builder: (context) => child,
              ).buildTransitions(context, animation, secondaryAnimation, child);
            },
          );
        },
      ),

      // EPUB Reader Route
      GoRoute(
        path: '/epub/:bookId',
        name: 'epub_reader',
        pageBuilder: (context, state) {
          final bookId = state.pathParameters['bookId']!;
          return CustomTransitionPage(
            key: state.pageKey,
            child: EpubReaderScreen(bookId: bookId),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return MaterialPageRoute(
                builder: (context) => child,
              ).buildTransitions(context, animation, secondaryAnimation, child);
            },
          );
        },
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      // About Route
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AboutScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'The page ${state.uri.path} does not exist.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Helper methods for navigation
  static void goToShelf(BuildContext context) {
    context.go('/');
  }

  static void goToPdfReader(BuildContext context, String bookId) {
    context.go('/pdf/$bookId');
  }

  static void goToEpubReader(BuildContext context, String bookId) {
    context.go('/epub/$bookId');
  }

  static void goToReader(BuildContext context, Book book) {
    switch (book.fileType) {
      case BookFileType.pdf:
        goToPdfReader(context, book.id);
        break;
      case BookFileType.epub:
        goToEpubReader(context, book.id);
        break;
    }
  }

  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void goToAbout(BuildContext context) {
    context.go('/about');
  }

  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      goToShelf(context);
    }
  }
}

// Route names for type safety
class RouteNames {
  static const String shelf = 'shelf';
  static const String pdfReader = 'pdf_reader';
  static const String epubReader = 'epub_reader';
  static const String settings = 'settings';
  static const String about = 'about';
}

// Route paths for reference
class RoutePaths {
  static const String shelf = '/';
  static const String pdfReader = '/pdf/:bookId';
  static const String epubReader = '/epub/:bookId';
  static const String settings = '/settings';
  static const String about = '/about';
}
