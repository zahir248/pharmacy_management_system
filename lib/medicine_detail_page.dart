import 'package:flutter/material.dart';
import '../models/medicine.dart';

class MedicineDetailPage extends StatefulWidget {
  final Medicine medicine;

  MedicineDetailPage({required this.medicine});

  @override
  _MedicineDetailPageState createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
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
                  height: 48.0, // Set a fixed height for the button
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Implement the logic for "Add to Cart" button
                    },
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
                SizedBox(
                  height: 48.0, // Set a fixed height for the button
                  child: ElevatedButton(
                    onPressed: () {
                      // Implement the logic for "Buy Now" button
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
    );
  }
}
