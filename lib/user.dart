import 'package:flutter/material.dart';
import 'package:useradmin/screen/main_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
      ),
      body: MainScreen()
      );
  }
}