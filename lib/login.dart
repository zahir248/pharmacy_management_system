import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/gestures.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> authenticateUser() async {
    try {
      final response = await http.post(
        Uri.parse('https://farmasee.000webhostapp.com/login.php'),
        body: {
          'username': _usernameController.text,
          'password': _passwordController.text,
        },
      );

      if (response.statusCode == 200) {
        // Successfully received response from the server
        if (response.body.trim() == 'success') {
          // User authenticated successfully
          print('Login successful'); // Add this line for debugging
          Fluttertoast.showToast(
            msg: 'Login successful!',
            backgroundColor: Colors.green, // Set the background color to green
            textColor: Colors.white, // Set the text color to white
          );

          // Save user session data to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('username', _usernameController.text);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        } else {
          // Authentication failed
          Fluttertoast.showToast(
            msg: 'Login failed!',
            backgroundColor: Colors.red, // Set the background color to red
            textColor: Colors.white, // Set the text color to white
          );
        }
      } else {
        // Failed to connect to the server
        Fluttertoast.showToast(msg: 'Failed to connect to the server. Error code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle other errors
      Fluttertoast.showToast(msg: 'An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Delivery System'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, left: 16.0, right: 16.0, bottom: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/pharmacystore.png',
                width: screenWidth * 1,
                height: screenWidth * 1,
              ),
              const SizedBox(height: 20),
              Container(
                width: screenWidth * 1.0,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: screenWidth * 1.0,
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: screenWidth * 1.0,
                child: ElevatedButton(
                  onPressed: () {
                    authenticateUser();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10), // Add space between the Login button and the text
              TextButton(
                onPressed: () async {
                  // Implement navigation to the registration page
                  await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Register()));
                },
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            // Add your navigation logic here when "Sign Up" is tapped
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const Register()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
