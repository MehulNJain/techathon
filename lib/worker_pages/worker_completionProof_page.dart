import 'package:flutter/material.dart';

class WorkerCompletionProofPage extends StatefulWidget {
  @override
  State<WorkerCompletionProofPage> createState() =>
      _WorkerCompletionProofPageState();
}

class _WorkerCompletionProofPageState extends State<WorkerCompletionProofPage> {
  final TextEditingController _notesController = TextEditingController();

  // Dummy image values; replace with your image picker logic
  List<ImageProvider?> _images = [null, null, null];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Completion Proof",
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              margin: EdgeInsets.only(bottom: 18),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(text: "Upload at least "),
                          TextSpan(
                            text: "1 photo",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: " (max 3) as proof of work completion.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Upload Photos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 11),
            Column(
              children: [
                _buildPhotoCard(0, "Photo 1 (Required)", true),
                _buildPhotoCard(1, "Photo 2 (Optional)", false),
                _buildPhotoCard(2, "Photo 3 (Optional)", false),
              ],
            ),
            SizedBox(height: 30),
            Text(
              "Additional Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            // Notes box
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.only(left: 8, top: 4, right: 8, bottom: 8),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add notes/remarks (optional)",
                ),
              ),
            ),
            SizedBox(height: 14),
            // Voice note row
            Row(
              children: [
                Text(
                  "Optional voice note",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Spacer(),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  icon: Icon(Icons.mic, size: 20),
                  label: Text(
                    "Record",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.check_circle, size: 22),
                label: Text(
                  "Mark Work Completed",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index, String label, bool required) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(blurRadius: 4, color: Colors.black12, offset: Offset(0, 2)),
        ],
      ),
      height: 115,
      child: InkWell(
        onTap: () {
          // Your image picker method goes here
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey.shade400,
                size: 28,
              ),
              radius: 26,
            ),
            SizedBox(height: 7),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            Text(
              "Tap to capture",
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
