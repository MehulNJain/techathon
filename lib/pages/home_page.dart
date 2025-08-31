import 'package:flutter/material.dart';
import 'reports_page.dart'; // Import your reports page

class HomePage extends StatefulWidget {
  final String fullName; // ✅ Accept full name from ProfilePage

  const HomePage({super.key, required this.fullName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to My Reports when Complaints tab is tapped
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyReportsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Smart Civic Portal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: width * 0.07,
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "Good morning,",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.035,
                    ),
                  ),
                  Text(
                    widget.fullName, // ✅ Dynamic name from ProfilePage
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.012,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Navigate to report page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyReportsPage(),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, size: width * 0.05),
                    label: Text(
                      "Report an Issue",
                      style: TextStyle(fontSize: width * 0.035),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            // Quick Report
            Text(
              "Quick Report",
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.015),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: height * 0.015,
              crossAxisSpacing: width * 0.04,
              childAspectRatio: 1.1,
              children: [
                _quickReportCard(
                  Icons.delete,
                  "Garbage",
                  Colors.green.shade100,
                  Colors.green,
                  width,
                ),
                _quickReportCard(
                  Icons.lightbulb_outline,
                  "Street Light",
                  Colors.yellow.shade100,
                  Colors.orange,
                  width,
                ),
                _quickReportCard(
                  Icons.traffic,
                  "Road Damage",
                  Colors.red.shade100,
                  Colors.red,
                  width,
                ),
                _quickReportCard(
                  Icons.water_drop,
                  "Water Supply",
                  Colors.blue.shade100,
                  Colors.blue,
                  width,
                ),
              ],
            ),

            SizedBox(height: height * 0.02),

            // Badge Card
            Container(
              padding: EdgeInsets.all(width * 0.04),
              decoration: BoxDecoration(
                color: Colors.purple.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Current Badge",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.035,
                    ),
                  ),
                  Text(
                    "Civic Hero 🧑‍🤝‍🧑",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width * 0.04,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  LinearProgressIndicator(
                    value: 0.7,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: height * 0.01,
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    "2 more reports to reach Neighborhood Guardian 🦸‍♂️",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width * 0.03,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: height * 0.02),

            // Report Summary
            Text(
              "Reports Summary",
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _summaryBox("12", "Total", Colors.black, width),
                _summaryBox("3", "Pending", Colors.orange, width),
                _summaryBox("9", "Resolved", Colors.green, width),
              ],
            ),

            SizedBox(height: height * 0.02),

            // Recent Reports
            Text(
              "Recent Reports",
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: height * 0.012),
            _reportItem(
              "Garbage - Overflowing Dustbin",
              "MG Road, Sector 14",
              "Pending",
              Colors.orange,
              width,
            ),
            _reportItem(
              "Street Light - Not Working",
              "Park Street, Block A",
              "In Progress",
              Colors.blue,
              width,
            ),
            _reportItem(
              "Road Damage - Pothole",
              "Main Road, Near Mall",
              "Resolved",
              Colors.green,
              width,
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        iconSize: width * 0.07,
        selectedFontSize: width * 0.03,
        unselectedFontSize: width * 0.03,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: "Report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Complaints",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Quick Report Card
  Widget _quickReportCard(
    IconData icon,
    String title,
    Color bgColor,
    Color iconColor,
    double width,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: width * 0.1),
          SizedBox(height: width * 0.02),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }

  // Report Summary Box
  Widget _summaryBox(String value, String label, Color color, double width) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: width * 0.01),
        Text(label, style: TextStyle(fontSize: width * 0.03)),
      ],
    );
  }

  // Recent Report Item
  Widget _reportItem(
    String title,
    String subtitle,
    String status,
    Color statusColor,
    double width,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: width * 0.015),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: width * 0.035,
          ),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: width * 0.03)),
        trailing: Container(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.025,
            vertical: width * 0.01,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: width * 0.03,
            ),
          ),
        ),
      ),
    );
  }
}
