import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'worker_home_page.dart';
import 'worker_myTasks_page.dart';
import 'worker_profile_page.dart';
import '../l10n/app_localizations.dart';

class WorkerMainPage extends StatefulWidget {
  const WorkerMainPage({super.key});

  @override
  State<WorkerMainPage> createState() => _WorkerMainPageState();
}

class _WorkerMainPageState extends State<WorkerMainPage> {
  int _selectedIndex = 0;

  // The list of pages to be displayed.
  // These pages should NOT have their own BottomNavigationBar.
  static const List<Widget> _pages = <Widget>[
    WorkerHomePage(),
    WorkerMyTasksPage(),
    WorkerProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      // The body now switches between the pages in the list.
      body: IndexedStack(index: _selectedIndex, children: _pages),
      // This is the SINGLE BottomNavigationBar for all pages.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedFontSize: 13.sp,
        unselectedFontSize: 12.sp,
        iconSize: 22.sp,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 22.sp),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, size: 22.sp),
            label: l10n.myTasks,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 22.sp),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
