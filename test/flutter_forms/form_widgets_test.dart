import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/flutter_forms/form_widgets.dart';
import 'package:form_testing/forms/forms.dart';
import 'package:mockito/mockito.dart';


class ControlMock extends Mock implements FormControl<String> {}

void main() {

  ControlMock mock;
  setUp(() {
    mock = ControlMock();
    when(mock.enabled).thenReturn(true);
    when(mock.displayErrors).thenReturn(false);
    when(mock.errors).thenReturn({});
  });

  testWidgets('Registers a view notifier with control', (WidgetTester tester) async {
    await pumpWithMaterial(tester, ControlledTextField(mock));
    final call = verify(mock.registerModelUpdatedListener(captureAny));
    call.called(1);
    expect(call.captured.length, 1);
    expect(call.captured[0] is ViewNotifier, true);
  });

  group('Text field value', () {
    testWidgets('displays initial control value', (WidgetTester tester) async {
      final control = FormControl<String>(initialValue: 'hi');
      await pumpWithMaterial(tester, ControlledTextField(control));
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('recieves updates from control', (WidgetTester tester) async {
      final control = FormControl<String>(initialValue: 'hi');
      await pumpWithMaterial(tester, ControlledTextField(control));
      control.setValue('gh');
      await tester.pump();
      expect(find.text('gh'), findsOneWidget);
    });
  });

  testWidgets('User input updates control', (WidgetTester tester) async{
    when(mock.enabled).thenReturn(true);
    await pumpWithMaterial(tester, ControlledTextField(mock));
    final textFinder = find.byType(TextField);
    verifyNever(mock.onViewValueUpdated(any));
    await tester.enterText(textFinder, 'cd');
    verify(mock.onViewValueUpdated('cd')).called(1);
  });

  group('Enabled status', () {
    group('Internal text field is:', () {
      testWidgets('enabled when control enabled', (WidgetTester tester) async {
        when(mock.enabled).thenReturn(true);
        await pumpWithMaterial(tester, ControlledTextField(mock));
        TextField field = tester.widget(find.byType(TextField));
        expect(field.enabled, true);
      });

      testWidgets('disabled when control disabled', (WidgetTester tester) async {
        when(mock.enabled).thenReturn(false);
        await pumpWithMaterial(tester, ControlledTextField(mock));
        TextField field = tester.widget(find.byType(TextField));
        expect(field.enabled, false);
      });
    });

    testWidgets('Changing enabled status updates field', (WidgetTester tester) async {
      final control = FormControl<String>(enabled: true);
      await pumpWithMaterial(tester, ControlledTextField(control));
      TextField field = tester.widget(find.byType(TextField));
      expect(field.enabled, true);
      control.setEnabled(false);
      await tester.pump();
      field = tester.widget(find.byType(TextField));
      expect(field.enabled, false);
    });
  });


  group('Error message:', () {
    group('when displayErrors is true,', () {
      ControlMock mock;
      setUp(() {
        mock = ControlMock();
        when(mock.displayErrors).thenReturn(true);
        when(mock.errors).thenReturn({'er1': 'hello', 'er2': 'foobar'});
      });
      test('is null when field disabled', () {
        when(mock.enabled).thenReturn(false);
        final field = ControlledTextField(mock);
        expect(field.errorText, null);
      });
      test('combines errors when field enabled', () {
        when(mock.enabled).thenReturn(true);
        final field = ControlledTextField(mock);
        expect(field.errorText, 'hello\nfoobar');
      });
    });
    group('when displayErrors is false,', () {
      ControlMock mock;
      setUp(() {
        mock = ControlMock();
        when(mock.displayErrors).thenReturn(false);
        when(mock.errors).thenReturn({'er1': 'hello', 'er2': 'foobar'});
      });
      test('is null when field disabled', () {
        when(mock.enabled).thenReturn(false);
        final field = ControlledTextField(mock);
        expect(field.errorText, null);
      });
      test('is also null when field enabled', () {
        when(mock.enabled).thenReturn(true);
        final field = ControlledTextField(mock);
        expect(field.errorText, null);
      });
    });

    testWidgets('is displayed in text field', (WidgetTester tester) async {
      when(mock.enabled).thenReturn(true);
      when(mock.displayErrors).thenReturn(true);
      when(mock.errors).thenReturn({'er1': 'howdy', 'er2': 'friend'});
      final field = ControlledTextField(mock);
      final errorText = field.errorText;
      await pumpWithMaterial(tester, field);
      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets('display is updated when control displayErrors changes', (WidgetTester tester) async {
      final validators = ValidatorSet.builder([MockValidator({'er1': 'blue', 'er2': 'sky'})]);
      final control = FormControl<String>(displayErrors: false, validators: validators);
      await pumpWithMaterial(tester, ControlledTextField(control));
      final errorFinder = find.text('blue\nsky');
      expect(errorFinder, findsNothing);
      control.setDisplayErrors(true);
      await tester.pump();
      expect(errorFinder, findsOneWidget);
    });
  });

  testWidgets('Display errors is set on field blur', (WidgetTester tester) async {
    await pumpWithMaterial(tester, Column(
      children: [
        ControlledTextField(mock),
        TextFormField()
      ]
    ));
    await tester.tap(find.byType(ControlledTextField));
    verifyNever(mock.setDisplayErrors(any));
    // Change focus to another text field
    await tester.tap(find.byType(TextFormField));
    verify(mock.setDisplayErrors(true)).called(1);
  });
  
}
Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}

class MockValidator extends Validator<String> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]): super([returnErrors]);

  final List<String> calledWithValues = List<String>();

  @override
  Map<String, dynamic> validate(AbstractControl<String> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }

}