import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/transaction.dart';
import '../models/medicine.dart';
import 'dashboard.dart'; // Import your dashboard page
import 'checkout.dart'; // Import your checkout page

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  late Future<List<Transaction>> futureTransactions;
  double totalPrice = 0.0;

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
        //Uri.parse('https://farmasee.000webhostapp.com/getInCart.php?username=$username'),
        Uri.parse('http://192.168.184.78/pharmacy/getInCart.php?username=$username'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Transaction.fromJson(item)).cast<Transaction>().toList();
      } else {
        // If there's an error or no data is fetched, return an empty list
        print('Failed to load transaction data. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      // If there's an error, return an empty list
      print('Error fetching transaction data: $e');
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Cart'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the dashboard page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()), // Replace with your dashboard page
            );
          },
        ),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: futureTransactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final transactions = snapshot.data!;
            if (transactions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      size: 100.0,
                      color: Colors.blue,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Your Shopping Cart is Empty',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              );
            } else {
              // Calculate the total price
              totalPrice = transactions.fold(0.0, (sum, transaction) => sum + (transaction.quantity * transaction.medicine.price));

              // Render your list of transactions here
              return Stack(
                children: [
                  ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      Transaction transaction = transactions[index];
                      Medicine medicine = transaction.medicine;

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          leading: Image.memory(
                            medicine.imageData,
                            height: 100.0,
                            width: 100.0,
                            fit: BoxFit.cover,
                          ),
                          title: Text(medicine.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8.0),
                              Text('\RM ${medicine.price.toString()}'),
                              SizedBox(height: 8.0),
                              Text('Quantity: ${transaction.quantity.toString()}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the checkout page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              totalPrice: totalPrice,
                              transactions: transactions,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        color: Colors.lightBlueAccent,
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Price: \RM ${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            SizedBox(width: 8.0),
                            Divider(height: 24, thickness: 2, color: Colors.black),
                            SizedBox(width: 8.0),
                            Row(
                              children: [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  'Checkout',
                                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(bottom: 200.0),
                  ),
                ],
              );
            }
          }
        },
      ),
    );
  }
}
