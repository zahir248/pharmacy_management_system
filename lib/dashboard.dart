import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Import the shared_preferences package
import '../models/medicine.dart';
import 'medicine_detail_page.dart';
import 'login.dart'; // Import the LoginPage
import 'package:fluttertoast/fluttertoast.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Medicine>> futureMedicines;

  @override
  void initState() {
    super.initState();
    futureMedicines = fetchMedicines();
  }

  Future<List<Medicine>> fetchMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.184.78/pharmacy/fetchMedicines.php'),
      );

      print('Raw JSON response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        return jsonData.map((item) => Medicine.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load medicine data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching medicine data: $e');
      throw Exception('Failed to load medicine data.');
    }
  }

  // Function to clear user data and navigate to login page
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if the user is already logged out
    if (prefs.getString('username') == null) {
      Fluttertoast.showToast(
        msg: 'You are already logged out!',
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    } else {
      //print('Before logout: ${prefs.getString('username')}');
      await prefs.clear(); // Clear all data in SharedPreferences
      //print('After logout: ${prefs.getString('username')}');

      Fluttertoast.showToast(
        msg: 'Logout successful!',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon
            onPressed: _logout, // Call the _logout function when pressed
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ),
            ),
            FutureBuilder<List<Medicine>>(
              future: futureMedicines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final medicines = snapshot.data!;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineDetailPage(
                                medicine: medicines[index],
                              ),
                            ),
                          );
                        },
                        child: buildMedicineCard(medicines[index]),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMedicineCard(Medicine medicine) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.memory(
            medicine.imageData,
            height: 100.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text('\RM ${medicine.price.toString()}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
