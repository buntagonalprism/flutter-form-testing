import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  /// This has a ramification that we can enter text into disabled input fields during a test,
  /// something a user should not normally be able to do.
  testWidgets('Disabled text field does not prevent tester.enterText', (WidgetTester tester) async {
    List<String> fieldInput = List<String>();
    await pumpWithMaterial(tester, TextField(
      enabled: false,
      onChanged: (value) => fieldInput.add(value),
    ));
    await tester.enterText(find.byType(TextField), 'hello');
    expect(fieldInput, ['hello']);
  });
}

Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}