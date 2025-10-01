import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ascenity_app/screens/dashboard_screen.dart';
import 'package:ascenity_app/screens/journaling_page.dart';
import 'package:ascenity_app/screens/streaks_screen.dart';
import 'package:ascenity_app/widgets/custom_nav_bar.dart';
import 'package:ascenity_app/screens/settings_page.dart';

/// Main application shell with custom bottom navigation and fluid page transitions.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _pages = const [
    DashboardScreen(),
    JournalingPage(),
    StreaksScreen(),
    SettingsPage(),
  ];
  
  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home'
    ),
    NavItem(
      icon: Icons.edit_note_outlined,
      selectedIcon: Icons.edit_note,
      label: 'Journal'
    ),
    NavItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.auto_graph,
      label: 'Progress'
    ),
    NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTapped,
        items: _navItems,
      ),
    );
  }
}
