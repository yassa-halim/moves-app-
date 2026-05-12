import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart' as di;
import '../../../auth/presentation/pages/profile_page.dart';
import '../bloc/movies_bloc.dart';
import 'explore_page.dart';
import 'home_page.dart';
import 'search_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    BlocProvider(
      create: (_) => di.sl<MoviesBloc>(),
      child: const HomePage(),
    ),
    BlocProvider(
      create: (_) => di.sl<MoviesBloc>(),
      child: const SearchPage(),
    ),
    BlocProvider(
      create: (_) => di.sl<MoviesBloc>(),
      child: const ExplorePage(),
    ),
    BlocProvider(
      create: (_) => di.sl<MoviesBloc>(),
      child: const ProfilePage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      extendBody: true, // Allows background to flow under the floating nav bar
      body: Stack(
        children: [
          // Main content preserved across tab switches
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
          // Floating Glassmorphism Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(Icons.home_filled, 0),
                      _buildNavItem(Icons.search_rounded, 1),
                      _buildNavItem(Icons.explore_rounded, 2),
                      _buildNavItem(Icons.person_rounded, 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: Icon(
            icon,
            color: isSelected ? AppTheme.primaryYellow : Colors.white.withOpacity(0.6),
            size: 28,
            shadows: isSelected
                ? [
                    Shadow(
                      color: AppTheme.primaryYellow.withOpacity(0.5),
                      blurRadius: 12,
                    )
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
