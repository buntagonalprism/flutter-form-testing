import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/ui/sign_up.dart';


void main() {
  testWidgets('Email field bound to control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, SignUpScreen(title: 'hello',));
    fail('Oops I broke it again');
  });
}

Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}