import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/account_disabled_screen.dart';
import '../screens/auth/auth_gate_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import 'integration_placeholders.dart';
import 'shell/main_navigation_shell.dart';

/// Centralized route paths for InkVerse.
class AppRoutes {
  AppRoutes._();

  // Public / Auth
  static const String gate = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String accountDisabled = '/account-disabled';

  // Reader Routes
  static const String home = '/home';
  static const String discover = '/discover';
  static const String library = '/library';
  static const String profile = '/profile';
  static const String novelDetail = '/novel/:id';
  static const String reading = '/novel/:id/chapter/:chapterId';
  static const String bookmarks = '/bookmarks';
  static const String history = '/history';

  // Author Routes
  static const String author = '/author';
  static const String authorNovels = '/author/novels';
  static const String authorNovelNew = '/author/novel/new';
  static const String authorNovelEdit = '/author/novel/:id';
  static const String authorChapters = '/author/novel/:id/chapters';
  static const String authorChapterNew = '/author/novel/:id/chapter/new';

  // Admin Routes
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminNovels = '/admin/novels';
  static const String adminReports = '/admin/reports';
  static const String adminGenres = '/admin/genres';

  // Route Path Generators
  static String novelDetailPath(String novelId) => '/novel/$novelId';
  static String readingPath(String novelId, String chapterId) =>
      '/novel/$novelId/chapter/$chapterId';
  static String authorNovelEditPath(String novelId) => '/author/novel/$novelId';
  static String authorChaptersPath(String novelId) =>
      '/author/novel/$novelId/chapters';
  static String authorChapterNewPath(String novelId) =>
      '/author/novel/$novelId/chapter/new';
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Creates GoRouter instance configured with authentication and role-based guards.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.gate,
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;

      // 1. If auth is not yet initialized or profile is currently loading on startup
      if (!authProvider.initialized ||
          (authProvider.currentUid != null &&
              authProvider.currentUser == null &&
              authProvider.loading)) {
        return loc == AppRoutes.gate ? null : AppRoutes.gate;
      }

      final isAuthenticated = authProvider.isAuthenticated;
      final isActive = authProvider.isActive;
      final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.register;
      final isDisabledRoute = loc == AppRoutes.accountDisabled;

      // 2. Unauthenticated user handling
      if (!isAuthenticated) {
        if (isAuthRoute) return null;
        return AppRoutes.login;
      }

      // 3. Inactive / disabled account handling
      if (!isActive) {
        if (isDisabledRoute) return null;
        return AppRoutes.accountDisabled;
      } else if (isDisabledRoute) {
        return AppRoutes.home;
      }

      // 4. Authenticated user attempting to visit login/register/gate
      if (isAuthRoute || loc == AppRoutes.gate) {
        if (authProvider.isAdmin) {
          return AppRoutes.admin;
        }
        return AppRoutes.home;
      }

      // 5. Author Route Guard: Reader attempting /author/* is redirected to /home
      if (loc.startsWith('/author')) {
        if (!authProvider.isAuthor && !authProvider.isAdmin) {
          return AppRoutes.home;
        }
      }

      // 6. Admin Route Guard: Reader or Author attempting /admin/* is redirected to /home
      if (loc.startsWith('/admin')) {
        if (!authProvider.isAdmin) {
          return AppRoutes.home;
        }
      }

      // Route allowed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.gate,
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountDisabled,
        builder: (context, state) => const AccountDisabledScreen(),
      ),

      // Reader Navigation Shell with Persistent Bottom NavigationBar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) =>
                    const ReaderHomePlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.discover,
                builder: (context, state) => const DiscoverPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.library,
                builder: (context, state) => const LibraryPlaceholderScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePlaceholderScreen(),
              ),
            ],
          ),
        ],
      ),

      // Reader Fullscreen Routes (Rendered outside Bottom NavigationBar)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.bookmarks,
        builder: (context, state) => const BookmarksPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.history,
        builder: (context, state) => const ReadingHistoryPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.novelDetail,
        builder: (context, state) {
          final novelId = state.pathParameters['id'] ?? '';
          return NovelDetailPlaceholderScreen(novelId: novelId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.reading,
        builder: (context, state) {
          final novelId = state.pathParameters['id'] ?? '';
          final chapterId = state.pathParameters['chapterId'] ?? '';
          return ReadingPlaceholderScreen(
            novelId: novelId,
            chapterId: chapterId,
          );
        },
      ),

      // Author Protected Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.author,
        builder: (context, state) => const AuthorDashboardPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.authorNovels,
        builder: (context, state) => const MyNovelsPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.authorNovelNew,
        builder: (context, state) => const NovelFormPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.authorNovelEdit,
        builder: (context, state) {
          final novelId = state.pathParameters['id'];
          return NovelFormPlaceholderScreen(novelId: novelId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.authorChapters,
        builder: (context, state) {
          final novelId = state.pathParameters['id'] ?? '';
          return ChapterManagementPlaceholderScreen(novelId: novelId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.authorChapterNew,
        builder: (context, state) {
          final novelId = state.pathParameters['id'] ?? '';
          return ChapterFormPlaceholderScreen(novelId: novelId);
        },
      ),

      // Admin Protected Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.admin,
        builder: (context, state) => const AdminDashboardPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminUsers,
        builder: (context, state) => const UserManagementPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminNovels,
        builder: (context, state) => const NovelModerationPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminReports,
        builder: (context, state) => const ReportManagementPlaceholderScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminGenres,
        builder: (context, state) => const GenreManagementPlaceholderScreen(),
      ),
    ],
  );
}
