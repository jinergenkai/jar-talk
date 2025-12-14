import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jar_talk/screens/explore/explore_screen.dart';
import 'package:jar_talk/screens/main_wrapper.dart';
import 'package:jar_talk/screens/profile/profile_screen.dart';
import 'package:jar_talk/screens/shelf/shelf_screen.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorShelfKey = GlobalKey<NavigatorState>(
    debugLabel: 'shelf',
  );
  static final _shellNavigatorExploreKey = GlobalKey<NavigatorState>(
    debugLabel: 'explore',
  );
  static final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
    debugLabel: 'profile',
  );

  static final GoRouter router = GoRouter(
    initialLocation: '/shelf',
    navigatorKey: _rootNavigatorKey,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorShelfKey,
            routes: [
              GoRoute(
                path: '/shelf',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ShelfScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorExploreKey,
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExploreScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
