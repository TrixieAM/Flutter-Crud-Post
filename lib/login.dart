import 'dart:convert';
import 'package:bsit3bcrud/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: unused_import
import 'package:bsit3bcrud/main.dart';
import 'package:bsit3bcrud/registration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> login() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showError("Please enter your username and password.");
      return;
    }

    final url = Uri.parse("http://localhost:5000/login");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const FacebookPost()),
  );
  showSuccess("Login successfully.");
} else {
  showError("Invalid username or password.");
}

    } catch (e) {
      showError("Error connecting to the server.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

 void showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      behavior: SnackBarBehavior.floating,
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: const Text(
          "facebook",
          style: TextStyle(
            fontSize: 40,
            color: Color(0xFF1877F2),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: "Username",
                prefixIcon: const Icon(Icons.person, color: Colors.grey),
                labelStyle: const TextStyle(color: Colors.grey), 
                floatingLabelStyle: const TextStyle(color: Colors.grey), 
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                labelStyle: const TextStyle(color: Colors.grey), 
                floatingLabelStyle: const TextStyle(color: Colors.grey), 
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    "Create New Account",
                    style: TextStyle(
                      color: Color(0xFF1877F2),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
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
