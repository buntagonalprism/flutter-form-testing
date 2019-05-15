import 'package:flutter/material.dart';
import 'package:form_testing/ui/sign_up.dart';

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color(0x11000000),
          isDense: true,
        ),
      ),
      home: SignUpScreen(title: 'Flutter Demo Home Page'),
    );
  }
}
