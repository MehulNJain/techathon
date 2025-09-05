import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../l10n/app_localizations.dart';
import 'worker_home_page.dart';
import 'worker_profile_page.dart';

class WorkerMyTasksPage extends StatefulWidget {
  const WorkerMyTasksPage({super.key});

  @override
  State<WorkerMyTasksPage> createState() => _WorkerMyTasksPageState();
}

class _WorkerMyTasksPageState extends State<WorkerMyTasksPage> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tabs = [
      l10n.filterAll,
      l10n.filterPending,
      l10n.filterInProgress,
      l10n.filterCompleted,
    ];

    final tasks = [
      TaskItem(
        id: '#CMP-2024-0892',
        title: l10n.roadMaintenance,
        subtitle: l10n.potholeRepair,
        location: 'MG Road, Near City Mall',
        priority: l10n.priorityHigh,
        status: l10n.filterPending,
        statusColor: Colors.orange.shade100,
        priorityColor: Colors.red.shade400,
        iconBg: Colors.orange.shade50,
        icon: Icons.construction,
      ),
      TaskItem(
        id: '#CMP-2024-0891',
        title: l10n.wasteManagement,
        subtitle: l10n.garbageCollection,
        location: 'Park Street, Block A',
        priority: l10n.priorityMedium,
        status: l10n.filterInProgress,
        statusColor: Colors.blue.shade100,
        priorityColor: Colors.orange.shade400,
        iconBg: Colors.green.shade50,
        icon: Icons.delete,
      ),
      TaskItem(
        id: '#CMP-2024-0890',
        title: l10n.streetLighting,
        subtitle: l10n.bulbReplacement,
        location: 'Gandhi Nagar, Sector 5',
        priority: l10n.priorityLow,
        status: l10n.filterCompleted,
        statusColor: Colors.green.shade100,
        priorityColor: Colors.green.shade400,
        iconBg: Colors.blue.shade50,
        icon: Icons.lightbulb,
      ),
    ];

    List<TaskItem> getFilteredTasks() {
      if (selectedTabIndex == 0) return tasks;
      String filter = tabs[selectedTabIndex];
      return tasks.where((t) => t.status == filter).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.orange.shade700,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          l10n.myTasks,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            alignment: Alignment.centerLeft,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final tab = entry.value;
                  final selected = selectedTabIndex == idx;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ChoiceChip(
                      label: Text(tab, style: TextStyle(fontSize: 13.sp)),
                      selected: selected,
                      selectedColor: Colors.orange.shade700,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedTabIndex = idx;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Task Cards
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: getFilteredTasks().length,
              separatorBuilder: (_, __) => SizedBox(height: 14.h),
              itemBuilder: (context, index) {
                final task = getFilteredTasks()[index];
                return Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 18.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Header
                        Row(
                          children: [
                            Text(
                              task.id,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                            ),
                            const Spacer(),
                            // Priority
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: task.priorityColor.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(13.r),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  color: task.priorityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 7.w),
                            // Status
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: task.statusColor,
                                borderRadius: BorderRadius.circular(13.r),
                              ),
                              child: Text(
                                task.status,
                                style: TextStyle(
                                  color: task.status == l10n.filterCompleted
                                      ? Colors.green.shade700
                                      : (task.status == l10n.filterPending
                                            ? Colors.orange.shade700
                                            : Colors.blue.shade700),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14.h),
                        // Task Details
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: task.iconBg,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              padding: EdgeInsets.all(12.w),
                              child: Icon(
                                task.icon,
                                color: Colors.orange.shade700,
                                size: 28.sp,
                              ),
                            ),
                            SizedBox(width: 13.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  Text(
                                    task.subtitle,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.grey.shade400,
                                        size: 15.sp,
                                      ),
                                      SizedBox(width: 5.w),
                                      Expanded(
                                        child: Text(
                                          task.location,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 13.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              l10n.viewDetails,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // My Tasks tab is selected
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WorkerHomePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WorkerProfilePage()),
            );
          }
          // index == 1 is current page, do nothing
        },
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

// Your TaskItem data model class.
class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String priority;
  final String status;
  final Color statusColor;
  final Color priorityColor;
  final Color iconBg;
  final IconData icon;

  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.priority,
    required this.status,
    required this.statusColor,
    required this.priorityColor,
    required this.iconBg,
    required this.icon,
  });
}
