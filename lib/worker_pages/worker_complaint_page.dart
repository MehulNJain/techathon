import 'package:flutter/material.dart';
import 'worker_completionProof_page.dart';
import 'worker_reportIssue_page.dart'; // Import the report issue page

class WorkerComplaintPage extends StatelessWidget {
  const WorkerComplaintPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
              onPressed: () => Navigator.pop(context),
            ),
            Text(
              'Complaint Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Complaint Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaint ID',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '#CMP001234',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.red.shade50,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red.shade400,
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Garbage Collection',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Overflowing Waste Bin',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'Sector 15, Block A, Near Market',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 6),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            minimumSize: Size(90, 36),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                          ),
                          onPressed: () {},
                          icon: Icon(
                            Icons.navigation,
                            size: 17,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Navigate',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 7),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'High Priority',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Spacer(),
                        Text(
                          '2 hours ago',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            // Citizen Submission Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citizen Submission',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Photos',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _imagePreview(
                          'https://img.icons8.com/color/96/garbage.png',
                        ),
                        SizedBox(width: 10),
                        _imagePreview(
                          'https://img.icons8.com/color/96/garbage.png',
                        ),
                        SizedBox(width: 10),
                        Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.grey.shade500,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'The garbage bin near the market is overflowing and waste is scattered around the area. This is causing hygiene issues and attracting stray animals.',
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 18),
                    // Voice note mockup
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            size: 28,
                            color: Colors.blue.shade800,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Voice Note',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    width: 120,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade300,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    '0:45 duration',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            // Buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Navigate to completion proof page on button click
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerCompletionProofPage(),
                  ),
                );
              },
              icon: Icon(Icons.camera_alt, size: 20),
              label: Text(
                'Upload Completion Photos',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow.shade100,
                foregroundColor: Colors.orange.shade900,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {},
              icon: Icon(Icons.build, size: 20),
              label: Text(
                'Mark as In Progress',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade400,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // Navigate to worker report issue page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkerReportIssuePage(),
                  ),
                );
              },
              icon: Icon(Icons.report_problem, size: 20),
              label: Text('Report Issue', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _imagePreview(String url) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
