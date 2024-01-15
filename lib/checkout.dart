import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dashboard.dart'; // Import your dashboard page

class CheckoutPage extends StatelessWidget {
  final double totalPrice;
  final List<Transaction> transactions;
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Define a global key

  CheckoutPage({
    Key? key,
    required this.totalPrice,
    required this.transactions,
  }) : super(key: key);

  Future<void> _placeOrder(String address, BuildContext context) async {
    // Check if the address is not empty
    if (address.trim().isEmpty) {
      // Show a toast with an error message
      Fluttertoast.showToast(
        msg: 'Please enter the shipping address',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    //final Uri apiUrl = Uri.parse('https://farmasee.000webhostapp.com/updateStatus.php');
    final Uri apiUrl = Uri.parse('http://192.168.184.78/pharmacy/updateStatus.php');

    try {
      for (Transaction transaction in transactions) {
        final String transactionId = transaction.transactionId.toString(); // Convert int to String

        final response = await http.post(
          apiUrl,
          body: {
            'transaction_id': transactionId,
            'address': address,
          },
        );

        if (response.statusCode == 200) {
          print('Order placed successfully for transaction id: $transactionId');
        } else {
          print('Failed to place order for transaction id: $transactionId. Server responded with status code ${response.statusCode}');
          return; // Stop execution if any transaction fails
        }
      }

      // Show a success toast message
      Fluttertoast.showToast(
        msg: 'Orders placed successfully!',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navigate to the dashboard page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // Replace with your dashboard page
      );

    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey, // Assign the global key to the scaffold
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Orders:',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  Transaction transaction = transactions[index];
                  return ListTile(
                    title: Text(transaction.medicine.name),
                    subtitle: Text('Quantity: ${transaction.quantity}'),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Please enter your shipping address',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 8.0),
            Container(
              width: screenWidth * 1.0,
              child: TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ListTile(
              title: Text(
                'Total Price: \RM ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _placeOrder(_addressController.text, context); // Pass the context to _placeOrder
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                child: Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
