import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dashboard.dart';

class CheckoutPage extends StatelessWidget {
  final Medicine medicine;
  final int quantity;
  final TextEditingController _addressController = TextEditingController();

  CheckoutPage({
    required this.medicine,
    required this.quantity,
  });

  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  Future<void> _placeOrder(BuildContext context) async {
    String username = await getUsername();
    String address = _addressController.text;

    // Check if the address is not empty
    if (address.isEmpty) {
      // Show an error message using FlutterToast
      Fluttertoast.showToast(
        msg: 'Please enter your shipping address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // Return from the method if the address is empty
    }

    final url = Uri.parse('https://farmasee.000webhostapp.com/addToBuy.php');
    //final url = Uri.parse('http://192.168.184.78/pharmacy/addToBuy.php');

    try {
      final response = await http.post(
        url,
        body: {
          'quantity': quantity.toString(),
          'username': username,
          'medicineId': medicine.medicineId.toString(),
          'address': address,
        },
      );

      if (response.statusCode == 200) {
        // Order placed successfully
        print('Order placed successfully');

        // Show a success message
        Fluttertoast.showToast(
          msg: 'Order placed successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        // Navigate to the dashboard page and replace the current route
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
      } else {
        // Failed to place order
        print('Failed to place order. Server responded with status code ${response.statusCode}');
      }
    } catch (e) {
      // Exception occurred
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = medicine.price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text('\RM ${medicine.price.toString()}'),
                    SizedBox(height: 20.0),
                    Text(
                      'Total Quantity: $quantity',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      'Please enter your shipping address:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0), // Add some space between the content and the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: Text(
                'Total Price: \RM ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: () => _placeOrder(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: Text('Place Order'),
              ),
            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
