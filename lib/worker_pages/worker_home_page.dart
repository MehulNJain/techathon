import 'package:flutter/material.dart';
import 'worker_complaint_page.dart';
import 'worker_profile_page.dart';
import 'worker_myTasks_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 55.w,
                  height: 55.w,
                  child: Image.asset(
                    complaint.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      size: 30.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: complaint.priorityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Text(
                            complaint.priority,
                            style: TextStyle(
                              color: complaint.priorityColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      complaint.location,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
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
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: complaint.statusColor,
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          child: Text(
                            complaint.status,
                            style: TextStyle(
                              color: complaint.status == 'Completed'
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
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

  Widget _buildHomeContent() {
    return Column(
      children: [
        WorkerDashboardHeader(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isSelected = selectedFilter == f;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ChoiceChip(
                    label: Text(f, style: TextStyle(fontSize: 13.sp)),
                    selected: isSelected,
                    selectedColor: Colors.orange.shade700,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => selectedFilter = f);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recent Complaints',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 70.h),
            itemCount: filteredComplaints.length,
            itemBuilder: (context, index) =>
                buildComplaintCard(filteredComplaints[index]),
          ),
        ),
      ],
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
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
    return WorkerProfilePage();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHomeContent(), Container(), _buildProfile()];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          // This container makes the orange color go behind the status bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).padding.top + 180.h,
            child: Container(color: Colors.orange.shade700),
          ),
          SafeArea(child: pages[bottomSelectedIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: bottomSelectedIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: Colors.orange.shade700,
        unselectedItemColor: Colors.grey.shade500,
        showUnselectedLabels: true,
        selectedFontSize: 13.sp,
        unselectedFontSize: 12.sp,
        iconSize: 22.sp,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 22.sp),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, size: 22.sp),
            label: "My Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 22.sp),
            label: "Profile",
          ),
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
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20.r,
                child: Icon(
                  Icons.account_balance,
                  color: Colors.orange.shade700,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Worker Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    'Municipal Services',
                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                  ),
                ],
              ),
              Spacer(),
              Icon(Icons.notifications, color: Colors.white, size: 22.sp),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.access_time,
                  iconBg: Colors.yellowAccent,
                  number: '12',
                  label: 'Pending',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _InfoCard(
                  icon: Icons.build,
                  iconBg: Colors.lightBlueAccent,
                  number: '8',
                  label: 'In Progress',
                ),
              ),
              SizedBox(width: 10.w),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.black87, size: 20.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
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
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => child!,
          child: child,
        );
      },
      home: WorkerHomePage(),
      theme: ThemeData(primarySwatch: Colors.orange),
    ),
  );
}
