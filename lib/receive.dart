import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dashboard.dart'; // Import your dashboard page file

class ReceivePage extends StatefulWidget {
  @override
  _ReceivePageState createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {

  late Future<List<Transaction>> futureTransactions;

  @override
  void initState() {
    super.initState();
    futureTransactions = fetchTransactions();
  }

  Future<List<Transaction>> fetchTransactions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? '';

    try {
      final response = await http.get(
        Uri.parse('https://farmasee.000webhostapp.com/transaction.php?username=$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Transaction.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load transactions. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      throw Exception('Failed to load transactions.');
    }
  }

  @override
  void dispose() {
    // Navigate to the dashboard page when the back button is pressed
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Navigate to the dashboard page and refresh it
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()),
      );
      return false; // Do not allow the back button to pop the current screen
    },
    child: Scaffold(
    appBar: AppBar(
    title: Text('Receive Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: futureTransactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final transactions = snapshot.data!;
                  if (transactions.isEmpty) {
                    return Center(child: Text('No transactions available.'));
                  }

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final medicine = transaction.medicine;
                      final totalPrice = transaction.quantity * medicine.price;

                      return Card(
                        elevation: 3, // Set the elevation as needed
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20), // Add spacing between image and text
                              Image.memory(
                                medicine.imageData,
                                width: 100, // Set the width as needed
                                height: 100, // Set the height as needed
                                fit: BoxFit.cover, // Adjust the fit as needed
                              ),
                              SizedBox(height: 20), // Add spacing between image and text
                              Text('Name: ${medicine.name}'),
                              SizedBox(height: 8), // Add spacing between image and text
                              Text('Total Price: RM ${totalPrice.toStringAsFixed(2)}'), // Display the total price
                              SizedBox(height: 8), // Add spacing between image and text
                              Text('Quantity: ${transaction.quantity}'),
                              SizedBox(height: 8), // Add spacing between image and text
                              Text('Address: ${transaction.address}'), // Display the address
                              SizedBox(height: 8), // Add spacing between image and text
                            ],
                          ),
                          // Add more UI elements or customize as needed
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Please be patient, your medicines will be delivered soon.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    )
    );
  }
}
