import 'package:flutter/material.dart';

class ReportIssuePage extends StatefulWidget {
  final String? prefilledCategory;

  const ReportIssuePage({Key? key, this.prefilledCategory}) : super(key: key);

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  String? selectedCategory;
  String? selectedSubcategory;
  List<String> categories = ['Garbage', 'Water', 'Road', 'Electricity'];
  List<String> subcategories = ['Overflowing bin', 'Littering', 'Dumping'];
  List<String> photos = [
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
  ];
  String location = 'MG Road, Sector 14, Gurgaon, Har';
  String gps = '28.4595, 77.0266';
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set prefilled category if provided
    if (widget.prefilledCategory != null &&
        categories.contains(widget.prefilledCategory)) {
      selectedCategory = widget.prefilledCategory;
    } else {
      selectedCategory = categories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text('Report an Issue'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category
            const Text(
              'Select Category',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Subcategory
            const Text(
              'Subcategory',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedSubcategory,
              hint: const Text('Select specific issue'),
              items: subcategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedSubcategory = v),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Photos
            Row(
              children: [
                const Text(
                  'Capture Photos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(' *', style: TextStyle(color: Colors.red)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(3, (i) {
                if (i < photos.length) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(photos[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => setState(() => photos.removeAt(i)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      // TODO: Implement photo capture
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade100,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  );
                }
              }),
            ),
            const SizedBox(height: 6),
            const Text(
              'At least 1 photo required. Up to 3 photos allowed.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Location
            const Text(
              'Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Auto-detected Location',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(location, style: const TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'GPS coordinates: $gps',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Additional Details
            const Text(
              'Additional Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter details...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),

            // Voice Note
            Row(
              children: [
                const Icon(Icons.mic, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Record voice note (optional)',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.blue),
                  onPressed: () {
                    // TODO: Implement voice note recording
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Submit Report',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // TODO: Submit logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
