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
    when(mock.touched).thenReturn(false);
    when(mock.submitRequested).thenReturn(false);
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


  group('Error message calculation:', () {
    ControlMock mock;
    setUp(() {
      mock = ControlMock();
      when(mock.errors).thenReturn({'er1': 'hello', 'er2': 'foobar'});
    });

    group('Should be', () {
      test('null when not enabled', () {
        setMockStates(mock, enabled: false, submitted: false, touched: false);
        expect(ControlledTextField(mock).errorText, null);

        setMockStates(mock, enabled: false, submitted: false, touched: true);
        expect(ControlledTextField(mock).errorText, null);

        setMockStates(mock, enabled: false, submitted: true, touched: false);
        expect(ControlledTextField(mock).errorText, null);

        setMockStates(mock, enabled: false, submitted: true, touched: true);
        expect(ControlledTextField(mock).errorText, null);
      });

      test('null when enabled but not touched or submitted', () {
        setMockStates(mock, enabled: true, submitted: false, touched: false);
        expect(ControlledTextField(mock).errorText, null);
      });

      test('Combine errors when enabled and either touched or submitted', () {
        setMockStates(mock, enabled: true, submitted: false, touched: true);
        expect(ControlledTextField(mock).errorText, 'hello\nfoobar');

        setMockStates(mock, enabled: true, submitted: true, touched: false);
        expect(ControlledTextField(mock).errorText, 'hello\nfoobar');

        setMockStates(mock, enabled: true, submitted: true, touched: true);
        expect(ControlledTextField(mock).errorText, 'hello\nfoobar');
      });
    });
  });

  group('Error message display: ', () {
    testWidgets('is withiin in text field', (WidgetTester tester) async {
      when(mock.enabled).thenReturn(true);
      when(mock.submitRequested).thenReturn(true);
      when(mock.errors).thenReturn({'er1': 'howdy', 'er2': 'friend'});
      final field = ControlledTextField(mock);
      final errorText = field.errorText;
      await pumpWithMaterial(tester, field);
      expect(find.text(errorText), findsOneWidget);
    });

    testWidgets('updated when control submit requested changes', (WidgetTester tester) async {
      final validators = ValidatorSet.builder([MockValidator({'er1': 'blue', 'er2': 'sky'})]);
      final control = FormControl<String>(validators: validators);
      await pumpWithMaterial(tester, ControlledTextField(control));
      final errorFinder = find.text('blue\nsky');
      expect(errorFinder, findsNothing);
      control.setSubmitRequested(true);
      await tester.pump();
      expect(errorFinder, findsOneWidget);
    });

    testWidgets('updated when control touched changes', (WidgetTester tester) async {
      final validators = ValidatorSet.builder([MockValidator({'er1': 'blue', 'er2': 'sky'})]);
      final control = FormControl<String>(validators: validators);
      await pumpWithMaterial(tester, ControlledTextField(control));
      final errorFinder = find.text('blue\nsky');
      expect(errorFinder, findsNothing);
      control.setTouched(true);
      await tester.pump();
      expect(errorFinder, findsOneWidget);
    });
  });

  testWidgets('touched is set on field blur', (WidgetTester tester) async {
    await pumpWithMaterial(tester, Column(
      children: [
        ControlledTextField(mock),
        TextFormField()
      ]
    ));
    await tester.tap(find.byType(ControlledTextField));
    verifyNever(mock.setSubmitRequested(any));
    // Change focus to another text field
    await tester.tap(find.byType(TextFormField));
    verify(mock.setTouched(true)).called(1);
  });
  
}
Future pumpWithMaterial(WidgetTester tester, Widget child) {
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: child,
    ),
  ));
}

void setMockStates(ControlMock mock, {bool enabled, bool touched, bool submitted}) {
  when(mock.enabled).thenReturn(enabled);
  when(mock.submitRequested).thenReturn(touched);
  when(mock.touched).thenReturn(submitted);
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