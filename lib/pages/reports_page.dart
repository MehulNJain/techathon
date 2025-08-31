import 'package:flutter/material.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  // Dummy report data
  final List<Map<String, dynamic>> reports = [
    {
      "title": "Garbage - Overflowing Dustbin",
      "location": "MG Road, Sector 14",
      "date": "Aug 31, 2:45 PM",
      "status": "Pending",
      "icon": Icons.delete,
      "image": "https://img.icons8.com/fluency/96/trash.png",
    },
    {
      "title": "Street Light - Not Working",
      "location": "Park Street, Block A",
      "date": "Aug 30, 11:20 AM",
      "status": "In Progress",
      "icon": Icons.lightbulb,
      "image": "assets/images/streetlight.webp", // ✅ Fixed
    },
    {
      "title": "Road Damage - Pothole",
      "location": "Main Road, Near Mall",
      "date": "Aug 29, 4:15 PM",
      "status": "Resolved",
      "icon": Icons.traffic,
      "image": "https://img.icons8.com/fluency/96/road-worker.png",
    },
    {
      "title": "Water Supply - Pipe Leakage",
      "location": "Residential Area, B-12",
      "date": "Aug 28, 9:30 AM",
      "status": "In Progress",
      "icon": Icons.water_drop,
      "image": "https://img.icons8.com/fluency/96/water.png",
    },
    {
      "title": "Garbage - Illegal Dumping",
      "location": "Market Road, Near Bus Stand",
      "date": "Aug 27, 6:45 PM",
      "status": "Resolved",
      "icon": Icons.delete_forever,
      "image": "https://img.icons8.com/fluency/96/trash.png",
    },
  ];

  String selectedTab = "All";

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter reports based on tab
    final filteredReports = selectedTab == "All"
        ? reports
        : reports.where((r) => r["status"] == selectedTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Reports"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _SummaryItem(title: "Total", value: "12", color: Colors.black),
                _SummaryItem(
                  title: "Pending",
                  value: "3",
                  color: Colors.orange,
                ),
                _SummaryItem(
                  title: "In Progress",
                  value: "4",
                  color: Colors.blue,
                ),
                _SummaryItem(
                  title: "Resolved",
                  value: "5",
                  color: Colors.green,
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var tab in ["All", "Pending", "In Progress", "Resolved"])
                  GestureDetector(
                    onTap: () => setState(() => selectedTab = tab),
                    child: _TabButton(label: tab, selected: selectedTab == tab),
                  ),
              ],
            ),
          ),

          // Reports List
          Expanded(
            child: ListView.builder(
              itemCount: filteredReports.length,
              itemBuilder: (context, index) {
                final report = filteredReports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        report["image"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                    title: Text(report["title"]),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report["location"]),
                        Text(report["date"]),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          report["status"],
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        report["status"],
                        style: TextStyle(
                          color: _getStatusColor(report["status"]),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Government of India Initiative – Secure & Verified",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// Summary Box
class _SummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// Tab Button
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;

  const _TabButton({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? Colors.blue : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
