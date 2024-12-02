import 'package:flutter/material.dart';

class LocationHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> travelHistory;
  final String _currentDate = DateTime.now().toIso8601String().split('T').first;
  LocationHistoryScreen({required this.travelHistory});

  @override
  Widget build(BuildContext context) {
    double totalDistance = 0;
    Duration totalDuration = Duration.zero;

    travelHistory.forEach((trip) {
      totalDistance += trip['distance'];
      totalDuration += trip['duration'];
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "Travel History",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 22, 28, 112),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Total Distance: ${totalDistance.toStringAsFixed(2)} km",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            Text(
              "Total Time: ${totalDuration.inHours}h ${totalDuration.inMinutes % 60}m",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: travelHistory.length,
                itemBuilder: (context, index) {
                  final trip = travelHistory[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        "Trip ${index + 1}: ${trip['distance'].toStringAsFixed(2)} km",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Date: ${_currentDate}\nDuration: ${trip['duration'].inHours}h ${trip['duration'].inMinutes % 60}m",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
