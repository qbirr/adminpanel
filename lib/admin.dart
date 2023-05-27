import 'package:flutter/material.dart';
import 'package:useradmin/screen/main_screen.dart';

class AdminScreen extends StatelessWidget {
  static const routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
      ),
      body: MainScreen()
    );
  }
}