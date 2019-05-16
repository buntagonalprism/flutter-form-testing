import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms/forms.dart';
import 'package:mockito/mockito.dart';

class ControlMock extends Mock implements FormControl<String> {}


void main() {

  final vsb = ValidatorSet.builder;

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
    expect(array.controls[1], secondMock);
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

  group('Validation', () {
    test('Default empty validator set', () {
      final emptyValidatorSet = ValidatorSet<List<String>>([]);
      final array = FormArray<String>(controls);
      expect(array.validators, emptyValidatorSet);
    });

    test('Initial validators stored', () {
      final validators = vsb([MockValidator({'oops':'an error'})]);
      final array = FormArray<String>(controls, validators: validators);
      expect(array.validators, validators);
    });

    test('Updated validators are stored', () {
      final array = FormArray<String>(controls);
      final validators = vsb([MockValidator({'oops':'an error'})]);
      array.setValidators(validators);
      expect(array.validators, validators);
    });

    test('Getting errors runs group validator', () {
      final validator = MockValidator({'oops':'an error'});
      final array = FormArray<String>(controls, validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      when(firstMock.value).thenReturn('123');
      when(secondMock.value).thenReturn('456');
      when(thirdMock.value).thenReturn('789');
      final errors = array.errors;
      expect(errors, {'oops':'an error'});
      expect(validator.calledWithValues[0][0], '123');
      expect(validator.calledWithValues[0][1], '456');
      expect(validator.calledWithValues[0][2], '789');
    });

    test('Getting errors combines all enabled child errors keyed by their index', () {
      final validator = MockValidator({'oops':'This is a group error'});
      final array = FormArray<String>(controls, validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      when(firstMock.errors).thenReturn({}); // Should not be present in group error - no errors
      when(secondMock.enabled).thenReturn(false); // Should not be present in group error - disabled
      when(secondMock.errors).thenReturn({'secondErr':'yes'});
      when(thirdMock.errors).thenReturn({'thirdErrOne': 'also', 'thirdErrTwo':'another'});
      final errors = array.errors;
      expect(errors, {
        'oops': 'This is a group error',
        'controlErrors': {
          '2': {
            'thirdErrOne': 'also',
            'thirdErrTwo': 'another'
          }
        }
      });
    });
  });

  group('Modifying controls', () {
    test('Adding notifies view and listeners', () {
      final array = FormArray<String>(controls);
      bool didChange = false;
      array.registerModelUpdatedListener(() {
        expect(array.controls.length, 4);
        didChange = true;
      });
      expect(array.valueUpdated, emitsInOrder([
        [null, null, null, 'a']
      ]));
      array.append(FormControl<String>(initialValue: 'a'));
      expect(didChange, true);
    });

    test('Inserting notifies view and listeners', () {
      final array = FormArray<String>(controls);
      bool didChange = false;
      array.registerModelUpdatedListener(() {
        expect(array.controls.length, 4);
        didChange = true;
      });
      expect(array.valueUpdated, emitsInOrder([
        [null, 'b', null, null]
      ]));
      array.insertAt(FormControl<String>(initialValue: 'b'), 1);
      expect(didChange, true);
    });

    test('Inserting notifies view and listeners', () {
      when(firstMock.value).thenReturn('1');
      when(secondMock.value).thenReturn('2');
      when(thirdMock.value).thenReturn('3');
      final array = FormArray<String>(controls);
      bool didChange = false;
      array.registerModelUpdatedListener(() {
        expect(array.controls.length, 2);
        didChange = true;
      });
      expect(array.valueUpdated, emitsInOrder([
        ['1', '3']
      ]));
      array.removeAt(1);
      expect(didChange, true);
    });
  });

  test('Enabled status change emitted to listeners', () {
    final array = FormArray<String>(controls);
    expect(array.enabledUpdated, emitsInOrder([false, true]));
    array.setEnabled(false);
    array.setEnabled(true);
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
