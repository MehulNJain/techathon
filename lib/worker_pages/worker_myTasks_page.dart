import 'package:flutter/material.dart';

class WorkerMyTasksPage extends StatefulWidget {
  @override
  State<WorkerMyTasksPage> createState() => _WorkerMyTasksPageState();
}

class _WorkerMyTasksPageState extends State<WorkerMyTasksPage> {
  int selectedTabIndex = 0;
  final tabs = ['All', 'Pending', 'In Progress', 'Completed'];

  final tasks = [
    TaskItem(
      id: '#CMP-2024-0892',
      title: 'Road Maintenance',
      subtitle: 'Pothole Repair',
      location: 'MG Road, Near City Mall',
      priority: 'High',
      status: 'Pending',
      statusColor: Colors.orange.shade100,
      priorityColor: Colors.red.shade400,
      iconBg: Colors.orange.shade50,
      icon: Icons.construction,
    ),
    TaskItem(
      id: '#CMP-2024-0891',
      title: 'Waste Management',
      subtitle: 'Garbage Collection',
      location: 'Park Street, Block A',
      priority: 'Medium',
      status: 'In Progress',
      statusColor: Colors.blue.shade100,
      priorityColor: Colors.orange.shade400,
      iconBg: Colors.green.shade50,
      icon: Icons.delete,
    ),
    TaskItem(
      id: '#CMP-2024-0890',
      title: 'Street Lighting',
      subtitle: 'Bulb Replacement',
      location: 'Gandhi Nagar, Sector 5',
      priority: 'Low',
      status: 'Completed',
      statusColor: Colors.green.shade100,
      priorityColor: Colors.green.shade400,
      iconBg: Colors.blue.shade50,
      icon: Icons.lightbulb,
    ),
  ];

  List<TaskItem> get filteredTasks {
    if (selectedTabIndex == 0) return tasks;
    String filter = tabs[selectedTabIndex];
    return tasks.where((t) => t.status == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "My Tasks",
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: tabs.asMap().entries.map((entry) {
                final idx = entry.key;
                final tab = entry.value;
                final selected = selectedTabIndex == idx;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTabIndex = idx;
                      });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.orange.shade700
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tab,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade600,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: filteredTasks.length,
              separatorBuilder: (_, __) => SizedBox(height: 14),
              itemBuilder: (context, index) {
                final task = filteredTasks[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              task.id,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.priorityColor.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                task.priority,
                                style: TextStyle(
                                  color: task.priorityColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: task.statusColor,
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                task.status,
                                style: TextStyle(
                                  color: task.status == 'Completed'
                                      ? Colors.green.shade700
                                      : (task.status == 'Pending'
                                            ? Colors.orange.shade700
                                            : Colors.blue.shade700),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: task.iconBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Icon(
                                task.icon,
                                color: Colors.orange.shade700,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Colors.grey[900],
                                    ),
                                  ),
                                  Text(
                                    task.subtitle,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.grey.shade400,
                                        size: 15,
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          task.location,
                                          style: TextStyle(
                                            fontSize: 13,
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
                            SizedBox(width: 8),
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: AssetImage(
                                'assets/images/avatar${index + 1}.png',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              "View Details",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
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
    );
  }
}

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
