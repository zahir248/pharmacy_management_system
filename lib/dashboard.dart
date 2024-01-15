import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';
import 'medicine_detail_page.dart';
import 'login.dart';
import 'shopping_cart_page.dart'; // Import your ShoppingCartPage file
import 'package:fluttertoast/fluttertoast.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Medicine>> futureMedicines;
  int cartCount = 0;
  int shipCount = 0; // New variable for shipping count

  @override
  void initState() {
    super.initState();
    futureMedicines = fetchMedicines();
    retrieveCartCount();
    retrieveShipCount(); // Call the method to retrieve shipping count
  }

  Future<void> retrieveShipCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    try {
      final response = await http.get(
        //Uri.parse('https://farmasee.000webhostapp.com/getShipCount.php?username=$username'),
        Uri.parse('http://192.168.184.78/pharmacy/getShipCount.php?username=$username'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          shipCount = jsonData['ship_count'];
        });
        print('Ship count: $shipCount');
      } else {
        throw Exception('Failed to retrieve ship count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving ship count: $e');
    }
  }

  Future<void> retrieveCartCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    try {
      final response = await http.get(
        //Uri.parse('https://farmasee.000webhostapp.com/getCartCount.php?username=$username'),
        Uri.parse('http://192.168.184.78/pharmacy/getCartCount.php?username=$username'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          cartCount = jsonData['cart_count'];
        });
        print('Cart count: $cartCount');
      } else {
        throw Exception('Failed to retrieve cart count. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error retrieving cart count: $e');
    }
  }

  Future<List<Medicine>> fetchMedicines() async {
    try {
      final response = await http.get(
        //Uri.parse('https://farmasee.000webhostapp.com/fetchMedicines.php'),
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('username') == null) {
      Fluttertoast.showToast(
        msg: 'You are already logged out!',
        backgroundColor: Colors.blue,
        textColor: Colors.white,
      );
    } else {
      await prefs.clear();
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

  Future<void> _navigateToShoppingCart() async {
    // Navigate to the shopping cart page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _navigateToShoppingCart,
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    cartCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.local_shipping),
                onPressed: () {
                  // Handle shipping icon pressed
                },
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    shipCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
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
