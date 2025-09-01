import 'package:flutter/material.dart';
import 'worker_complaint_page.dart';
import 'worker_profile_page.dart';
import 'worker_myTasks_page.dart'; // Import the My Tasks page

class WorkerHomePage extends StatefulWidget {
  @override
  _WorkerHomePageState createState() => _WorkerHomePageState();
}

class _WorkerHomePageState extends State<WorkerHomePage> {
  String selectedFilter = 'All';
  int bottomSelectedIndex = 0;

  final filters = ['All', 'Pending', 'In Progress', 'Completed'];

  final complaints = [
    ComplaintItem(
      id: '#CMP001234',
      title: 'Garbage Collection',
      location: 'Sector 15, Block A',
      priority: 'High',
      status: 'Pending',
      statusColor: Colors.orange.shade100,
      priorityColor: Colors.red.shade400,
      imageUrl: 'assets/images/garbage.png',
    ),
    ComplaintItem(
      id: '#CMP001235',
      title: 'Street Light',
      location: 'Main Road, Near Park',
      priority: 'Medium',
      status: 'In Progress',
      statusColor: Colors.blue.shade100,
      priorityColor: Colors.orange.shade400,
      imageUrl: 'assets/images/streetlight.png',
    ),
    ComplaintItem(
      id: '#CMP001236',
      title: 'Road Damage',
      location: 'Industrial Area Road',
      priority: 'High',
      status: 'Pending',
      statusColor: Colors.orange.shade100,
      priorityColor: Colors.red.shade400,
      imageUrl: 'assets/images/road-damage.png',
    ),
    ComplaintItem(
      id: '#CMP001237',
      title: 'Water Supply',
      location: 'Residential Colony',
      priority: 'Low',
      status: 'Completed',
      statusColor: Colors.green.shade100,
      priorityColor: Colors.green.shade400,
      imageUrl: 'assets/images/water-supply.png',
    ),
  ];

  List<ComplaintItem> get filteredComplaints {
    if (selectedFilter == 'All') return complaints;
    return complaints.where((c) => c.status == selectedFilter).toList();
  }

  Widget buildComplaintCard(ComplaintItem complaint) {
    return GestureDetector(
      onTap: () {
        if (complaint.title == 'Garbage Collection') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WorkerComplaintPage()),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 55,
                  height: 55,
                  child: Image.asset(
                    complaint.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image, size: 30, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: complaint.priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            complaint.priority,
                            style: TextStyle(
                              color: complaint.priorityColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complaint.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            complaint.id,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: complaint.statusColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            complaint.status,
                            style: TextStyle(
                              color: complaint.status == 'Completed'
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Home content widget with header, filters, and complaints list
  Widget _buildHomeContent() {
    return Column(
      children: [
        const WorkerDashboardHeader(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 6,
            children: filters.map((f) {
              final isSelected = selectedFilter == f;
              return ChoiceChip(
                label: Text(f),
                selected: isSelected,
                selectedColor: Colors.orange.shade700,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) {
                  setState(() => selectedFilter = f);
                },
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Complaints',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 70),
            itemCount: filteredComplaints.length,
            itemBuilder: (context, index) =>
                buildComplaintCard(filteredComplaints[index]),
          ),
        ),
      ],
    );
  }

  // Navigate to MyTasksPage when "My Tasks" tab or button is selected
  void _onBottomNavTapped(int index) {
    if (index == 1) {
      // Navigate to My Tasks page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WorkerMyTasksPage()),
      );
      return;
    }
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  Widget _buildProfile() {
    return const WorkerProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHomeContent(), Container(), _buildProfile()];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(child: pages[bottomSelectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomSelectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "My Tasks",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class WorkerDashboardHeader extends StatelessWidget {
  const WorkerDashboardHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade700,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: Icon(
                  Icons.account_balance,
                  color: Colors.orange.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Worker Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Municipal Services',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.notifications, color: Colors.white, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _InfoCard(
                  icon: Icons.access_time,
                  iconBg: Colors.yellowAccent,
                  number: '12',
                  label: 'Pending',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  icon: Icons.build,
                  iconBg: Colors.lightBlueAccent,
                  number: '8',
                  label: 'In Progress',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _InfoCard(
                  icon: Icons.check_circle,
                  iconBg: Colors.lightGreenAccent,
                  number: '45',
                  label: 'Completed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String number;
  final String label;

  const _InfoCard({
    Key? key,
    required this.icon,
    required this.iconBg,
    required this.number,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

class ComplaintItem {
  final String id;
  final String title;
  final String location;
  final String priority;
  final String status;
  final Color statusColor;
  final Color priorityColor;
  final String imageUrl;

  ComplaintItem({
    required this.id,
    required this.title,
    required this.location,
    required this.priority,
    required this.status,
    required this.statusColor,
    required this.priorityColor,
    required this.imageUrl,
  });
}

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worker Dashboard',
      home: WorkerHomePage(),
      theme: ThemeData(primarySwatch: Colors.orange),
    ),
  );
}
