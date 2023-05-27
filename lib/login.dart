import 'package:flutter/material.dart';
import 'package:useradmin/responsive.dart';

import 'login_widget.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Responsive(
        mobile: LoginForm(),
        desktop: Center(
          child: Container(
            width: 400.0,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LoginForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}