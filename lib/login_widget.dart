import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:useradmin/screen/main_screen.dart';

class LoginForm extends StatefulWidget {
  static const routeName = '/LoginForm';
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Get the current user's ID
      String userId = userCredential.user!.uid;

      // Check if the user exists in the 'admin' collection with role 'admin'
      DocumentSnapshot adminSnapshot = await _firestore
          .collection('admin')
          .doc(userId)
          .get();

      if (adminSnapshot.exists) {
        Map<String, dynamic>? adminData = adminSnapshot.data() as Map<String, dynamic>?;
        String? role = adminData?['role'] as String?;
        print('Role: $role');

        if (role == 'admin') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Successful'),
                content: Text('You are logged in as admin.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()));
                    },
                  ),
                ],
              );
            },
          );
          return;
        }
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text('You are not authorized to access the admin panel.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
               Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Login failed, show error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Login Failed'),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 16.0),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
            ),
            obscureText: true,
          ),
          SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: () => _login(context),
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
