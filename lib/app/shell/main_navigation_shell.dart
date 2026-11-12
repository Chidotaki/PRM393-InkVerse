import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../router.dart';

/// Reusable application shell providing a Material 3 [NavigationBar] for Reader destinations:
/// 1. Home (`/home`)
/// 2. Discover (`/discover`)
/// 3. Library (`/library`)
/// 4. Profile (`/profile`)
///
/// Designed for Member 2 (Reader UI) and Member 3 (Author/Admin UI) integration.
/// Fullscreen views (Novel Detail, Reading Screen, Author Studio, Admin Console)
/// remain top-level routes outside this shell so bottom navigation is hidden.
class MainNavigationShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainNavigationShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          // If logged in as Author or Admin, show a subtle studio/admin shortcut banner
          if (auth.isAuthor || auth.isAdmin)
            Material(
              color: auth.isAdmin
                  ? Colors.purple.shade700
                  : Colors.teal.shade700,
              elevation: 2,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        auth.isAdmin
                            ? Icons.admin_panel_settings
                            : Icons.edit_note,
                        size: 18,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        auth.isAdmin
                            ? 'InkVerse Admin Mode'
                            : 'Author Mode Active',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: Text(
                          auth.isAdmin ? 'Admin Console' : 'Author Studio',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () {
                          if (auth.isAdmin) {
                            context.push(AppRoutes.admin);
                          } else {
                            context.push(AppRoutes.author);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_library_outlined),
            selectedIcon: Icon(Icons.local_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
