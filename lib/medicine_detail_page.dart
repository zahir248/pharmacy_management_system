import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dashboard.dart'; // Import your DashboardPage file
import 'checkout_buy.dart';

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine;

  MedicineDetailPage({required this.medicine});

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  int quantity = 1;

  Future<String> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  Future<void> addToCart() async {
    String username = await getUsername();

    final url = Uri.parse('https://farmasee.000webhostapp.com/addToCart.php');
    //final url = Uri.parse('http://192.168.184.78/pharmacy/addToCart.php');

    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'medicine_id': widget.medicine.medicineId.toString(),
          'quantity': quantity.toString(),
        },
      );

      if (response.statusCode == 200) {
        // Handle the server's response
        print('Response: ${response.body}');

        // Check if the response indicates success
        if (response.body.toLowerCase().contains('success')) {
          // Show success message using Fluttertoast
          Fluttertoast.showToast(
            msg: 'Item added to cart successfully!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
        } else {
          // Show any other response message as needed
          Fluttertoast.showToast(
            msg: response.body,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        print('HTTP request failed with status: ${response.statusCode}');
        // Handle HTTP error
      }
    } catch (e) {
      print('Exception: $e');
      // Handle exceptions
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardPage()),
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.memory(
                widget.medicine.imageData,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 16.0),
              Text(
                widget.medicine.name,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              Text('\RM ${widget.medicine.price.toString()}'),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Quantity: ',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Container(
                    height: 24.0,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (quantity > 1) {
                              setState(() {
                                quantity--;
                              });
                            }
                          },
                        ),
                        VerticalDivider(
                          width: 1.0,
                          color: Colors.black,
                        ),
                        Container(
                          width: 20.0,
                          child: Center(
                            child: Text(
                              '$quantity',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          width: 1.0,
                          color: Colors.black,
                        ),
                        IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 48.0,
                    child: ElevatedButton.icon(
                      onPressed: addToCart,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Add to Cart'),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  // Inside _MedicineDetailPageState class
                  SizedBox(
                    height: 48.0,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to CheckoutPage and pass necessary data
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutPage(
                              medicine: widget.medicine,
                              quantity: quantity,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.all(16),
                      ),
                      child: Text('Buy Now'),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}