import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'worker_complaint_page.dart';
import 'package:intl/intl.dart';

class WorkerMyTasksPage extends StatefulWidget {
  const WorkerMyTasksPage({super.key});

  @override
  State<WorkerMyTasksPage> createState() => _WorkerMyTasksPageState();
}

class _WorkerMyTasksPageState extends State<WorkerMyTasksPage> {
  int selectedTabIndex = 0;

  List<TaskItem> tasks = [];
  String? _workerId;

  @override
  void initState() {
    super.initState();
    _loadWorkerIdAndTasks();
  }

  Future<void> _loadWorkerIdAndTasks() async {
    final prefs = await SharedPreferences.getInstance();
    _workerId = prefs.getString('workerId');
    if (_workerId != null) {
      await _fetchAssignedTasks();
      setState(() {});
    }
  }

  Future<void> _fetchAssignedTasks() async {
    final dbRef = FirebaseDatabase.instance.ref().child('complaints');
    final snapshot = await dbRef
        .orderByChild('assignedTo')
        .equalTo(_workerId)
        .get();

    final List<TaskItem> fetchedTasks = [];
    if (snapshot.exists && snapshot.value != null) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      data.forEach((key, value) {
        final complaintData = Map<String, dynamic>.from(value);
        fetchedTasks.add(
          TaskItem(
            id: key,
            title: complaintData['category'] ?? 'Unknown',
            subtitle: complaintData['subcategory'] ?? '',
            location: complaintData['location'] ?? '',
            status: complaintData['status'] ?? 'Pending',
            statusColor: _getStatusColor(complaintData['status']),
            iconBg: _getCategoryBgColor(complaintData['category']),
            icon: _getCategoryIcon(complaintData['category']),
            dateTime: complaintData['dateTime'] ?? '', // <-- Add this
          ),
        );
      });
    }
    setState(() {
      tasks = fetchedTasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tabs = [
      l10n.filterAll,
      l10n.assigned,
      l10n.inProgress,
      l10n.resolved,
    ];

    List<TaskItem> getFilteredTasks() {
      if (selectedTabIndex == 0) return tasks;
      String filter = tabs[selectedTabIndex];
      return tasks.where((t) => t.status == filter).toList();
    }

    int assignedCount = tasks.where((t) => t.status == 'Assigned').length;
    int inProgressCount = tasks.where((t) => t.status == 'In Progress').length;
    int resolvedCount = tasks.where((t) => t.status == 'Resolved').length;

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
          // Status Cards (same as WorkerHomePage)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SimpleStatusCard(
                      number: assignedCount.toString(),
                      label: l10n.assigned,
                    ),
                    _SimpleStatusCard(
                      number: inProgressCount.toString(),
                      label: l10n.inProgress,
                    ),
                    _SimpleStatusCard(
                      number: resolvedCount.toString(),
                      label: l10n.resolved,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tabs
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
          // Reduce gap between filter and complaints
          SizedBox(height: 4.h),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchAssignedTasks,
              child: getFilteredTasks().isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 40.h),
                        Center(
                          child: Text(
                            "No tasks assigned to you.",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        top: 4.h,
                        bottom: 16.h,
                      ),
                      itemCount: getFilteredTasks().length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final task = getFilteredTasks()[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkerComplaintPage(complaintId: task.id),
                              ),
                            );
                          },
                          child: buildTaskCard(task),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(TaskItem task) {
    final l10n = AppLocalizations.of(context)!; // Get localizations
    String formattedDate = '';
    try {
      final dt = DateTime.parse(task.dateTime);
      formattedDate = DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      formattedDate = task.dateTime;
    }

    // Icon and background color logic
    Color iconBg;
    Color iconColor;
    switch (task.title.split(' - ').first) {
      case "Garbage":
        iconBg = const Color(0xFFEAF8ED);
        iconColor = Colors.green;
        break;
      case "Street Light":
        iconBg = const Color(0xFFFFF9E5);
        iconColor = Colors.orange;
        break;
      case "Road Damage":
        iconBg = const Color(0xFFFFEAEA);
        iconColor = Colors.red;
        break;
      case "Water":
        iconBg = const Color(0xFFEAF4FF);
        iconColor = const Color(0xFF1746D1);
        break;
      case "Drainage & Sewerage":
        iconBg = const Color(0xFFEAF4FF);
        iconColor = const Color(0xFF1746D1);
        break;
      default:
        iconBg = Colors.grey.shade100;
        iconColor = Colors.grey;
    }

    // Status chip color logic
    Color chipBg;
    Color chipText;
    switch (task.status) {
      case 'Resolved':
        chipBg = Colors.green.shade50;
        chipText = Colors.green.shade700;
        break;
      case 'In Progress':
        chipBg = Colors.blue.shade50;
        chipText = Colors.blue.shade700;
        break;
      case 'Assigned':
        chipBg = Colors.purple.shade50;
        chipText = Colors.purple.shade700;
        break;
      default:
        chipBg = Colors.grey.shade100;
        chipText = Colors.grey;
    }

    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon in rounded square
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(task.title),
                  color: iconColor,
                  size: 24.sp,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${task.title}${task.subtitle.isNotEmpty ? ' - ${task.subtitle}' : ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Status chip
            Container(
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: chipBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _getStatusLabel(task.status, l10n), // Use translated status
                style: TextStyle(
                  color: chipText,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status, AppLocalizations loc) {
    switch (status) {
      case "Assigned":
        return loc.assigned;
      case "In Progress":
        return loc.inProgress;
      case "Resolved":
        return loc.resolved;
      default:
        return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade100;
      case 'In Progress':
        return Colors.blue.shade100;
      case 'Assigned':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getCategoryBgColor(String? category) {
    final mainCategory = (category ?? '').split(' - ').first;
    switch (mainCategory) {
      case "Garbage":
        return const Color(0xFFEAF8ED);
      case "Street Light":
        return const Color(0xFFFFF9E5);
      case "Road Damage":
        return const Color(0xFFFFEAEA);
      case "Water":
      case "Drainage & Sewerage":
        return const Color(0xFFEAF4FF);
      default:
        return Colors.grey.shade100;
    }
  }

  IconData _getCategoryIcon(String? category) {
    final mainCategory = (category ?? '').split(' - ').first;
    switch (mainCategory) {
      case "Garbage":
        return Icons.delete;
      case "Street Light":
        return Icons.lightbulb_outline;
      case "Road Damage":
        return Icons.traffic;
      case "Water":
        return Icons.water_drop;
      case "Drainage & Sewerage":
        return Icons.water_damage_outlined;
      default:
        return Icons.report_problem;
    }
  }

  Color _getCategoryIconColor(String category) {
    final mainCategory = category.split(' - ').first;
    switch (mainCategory) {
      case "Garbage":
        return Colors.green;
      case "Street Light":
        return Colors.orange;
      case "Road Damage":
        return Colors.red;
      case "Water":
      case "Drainage & Sewerage":
        return const Color(0xFF1746D1);
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat.yMMMd().add_jm().format(dt);
    } catch (_) {
      return dateTime;
    }
  }

  Color _getStatusChipTextColor(String status) {
    switch (status) {
      case 'Resolved':
        return Colors.green.shade700;
      case 'In Progress':
        return Colors.blue.shade700;
      case 'Assigned':
        return Colors.purple.shade700;
      default:
        return Colors.grey;
    }
  }
}

class TaskItem {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String status;
  final Color statusColor;
  final Color iconBg;
  final IconData icon;
  final String dateTime; // <-- Add this

  TaskItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.iconBg,
    required this.icon,
    required this.dateTime, // <-- Add this
  });
}

class _SimpleStatusCard extends StatelessWidget {
  final String number;
  final String label;

  const _SimpleStatusCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
      ],
    );
  }
}
