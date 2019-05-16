import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms/forms.dart';
import 'package:mockito/mockito.dart';

class ControlMock extends Mock implements FormControl<String> {}


void main() {

  ControlMock firstMock;
  ControlMock secondMock;
  ControlMock thirdMock;
  List<AbstractControl<String>> controls;

  setUp(() {
    firstMock = ControlMock();
    when(firstMock.enabled).thenReturn(true);
    when(firstMock.errors).thenReturn({});
    secondMock = ControlMock();
    when(secondMock.enabled).thenReturn(true);
    when(secondMock.errors).thenReturn({});
    thirdMock = ControlMock();
    when(thirdMock.enabled).thenReturn(true);
    when(thirdMock.errors).thenReturn({});
    controls = [firstMock, secondMock, thirdMock];
  });

  group('Initialisation passes down', () {
    test('Value when supplied', () {
      FormArray<String>(controls, initialValue: ['a', 'b', 'qwerty']);
      verify(firstMock.setValue('a')).called(1);
      verify(secondMock.setValue('b')).called(1);
      verify(thirdMock.setValue('qwerty')).called(1);
    });

    test('no value when not supplied', () {
      FormArray<String>(controls);
      verifyNever(firstMock.setValue(any));
      verifyNever(secondMock.setValue(any));
      verifyNever(thirdMock.setValue(any));
    });

    test('enabled status when supplied', () {
      final array = FormArray<String>(controls, enabled: false);
      expect(array.enabled, false);
      verify(firstMock.setEnabled(false)).called(1);
      verify(secondMock.setEnabled(false)).called(1);
      verify(thirdMock.setEnabled(false)).called(1);
    });

    test('no enabled status when not supplied', () {
      final array = FormArray<String>(controls);
      expect(array.enabled, true);
      verifyNever(firstMock.setEnabled(any));
      verifyNever(secondMock.setEnabled(any));
      verifyNever(thirdMock.setEnabled(any));
    });
  });

  group('Get value', () {
    test('Value combines child values', () {
      final array = FormArray<String>(controls);
      when(firstMock.value).thenReturn('1');
      when(secondMock.value).thenReturn('2');
      when(thirdMock.value).thenReturn('3');
      expect(array.value, ['1', '2', '3']);
    });

    test('Disabled children are not added to value', () {
      final array = FormArray<String>(controls);
      when(firstMock.value).thenReturn('1');
      when(secondMock.enabled).thenReturn(false);
      when(secondMock.value).thenReturn('2');
      when(thirdMock.value).thenReturn('3');
      expect(array.value, ['1', '3']);
    });
  });


  test('Get controller by index', () {
    final array = FormArray<String>(controls);
    expect(array.getControl(1), secondMock);
  });

  group('Updates are passed down to all children', () {

    test('Value', () {
      final array = FormArray<String>(controls);
      final data = ['tyu', 'ikm', 'dfg'];
      array.setValue(data);
      verify(firstMock.setValue('tyu')).called(1);
      verify(secondMock.setValue('ikm')).called(1);
      verify(thirdMock.setValue('dfg')).called(1);
    });

    test('submitRequest status', () {
      final array = FormArray<String>(controls);
      verifyNever(firstMock.setSubmitRequested(any));
      array.setSubmitRequested(false);
      verify(firstMock.setSubmitRequested(false)).called(1);
      verify(secondMock.setSubmitRequested(false)).called(1);
      verify(thirdMock.setSubmitRequested(false)).called(1);
    });

    test('enabled status', () {
      final array = FormArray<String>(controls);
      verifyNever(firstMock.setEnabled(any));
      array.setEnabled(true);
      verify(firstMock.setEnabled(true)).called(1);
      verify(secondMock.setEnabled(true)).called(1);
      verify(thirdMock.setEnabled(true)).called(1);
    });
  });

}

class MockValidator extends Validator<List<String>> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]): super([returnErrors]);

  final List<List<String>> calledWithValues = List<List<String>>();

  @override
  Map<String, dynamic> validate(AbstractControl<List<String>> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }
}
