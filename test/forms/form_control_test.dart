import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms/forms.dart';

void main() {
  final vb = ValidatorSet.builder;
  MockValidator withErrorValidator;
  MockValidator noErrorValidator;
  Map<String, dynamic> error;

  setUp(() {
    error = {'ohNo':'an error occured'};
    withErrorValidator = MockValidator(error);
    noErrorValidator = MockValidator(null);
  });

  group('Initialisation', () {
    test('Value and validators stored in control', () {
      final control = FormControl(initialValue: 'surprise', validators: vb([noErrorValidator]));
      expect(control.value, 'surprise');
      expect(control.validators, vb([noErrorValidator]));
    });
    test('Validators run against initial value', () {
      final control = FormControl(initialValue: 'abc', validators: vb([withErrorValidator]));
      expect(withErrorValidator.calledWithValues, ['abc']);
      expect(control.errors, error);
    });
    test('Error output defaults to empty map', () {
      final control = FormControl(initialValue: 'abc');
      expect(control.errors, {});
    });
  });



  group('Setting value', () {
    test('Updates control value', () {
      final control = FormControl<String>();
      expect(control.value, null);
      control.setValue('updated');
      expect(control.value, 'updated');
    });

    test('runs validation', () {
      final control = FormControl<String>(validators: vb([noErrorValidator]));
      control.onViewValueUpdated('foobar');
      expect(noErrorValidator.calledWithValues, [null, 'foobar']);
    });

    test('updates value listeners', () {
      final control = FormControl<String>(initialValue: 'initialNotEmitted');
      expect(control.valueUpdated, emitsInOrder([
        '123'
      ]));
      control.setValue('123');
    });

    test('updates view with value and errors', () {
      final control = FormControl<String>(validators: vb([withErrorValidator]));
      bool didChange = false;
      control.registerModelUpdatedListener(() {
        expect(control.value, 'abc');
        expect(control.errors, error);
        didChange = true;
      });
      control.setValue('abc');
      expect(didChange, true);
    });
  });


  group('updating validators', () {
    test('Updates control validators', () {
      final control = FormControl<String>(initialValue: '678', validators: vb([noErrorValidator]));
      control.setValidators(vb([withErrorValidator]));
      expect(control.validators, vb([withErrorValidator]));
    });

    test('runs validation and sets error', () {
      final control = FormControl<String>(initialValue: '678', validators: vb([noErrorValidator]));
      expect(noErrorValidator.calledWithValues, ['678']);
      expect(control.errors, {});
      control.setValidators(vb([withErrorValidator]));
      expect(withErrorValidator.calledWithValues, ['678']);
      expect(control.errors, error);
    });

    test('updates view with errors', () {
      final control = FormControl<String>(validators: vb([noErrorValidator]));
      control.registerModelUpdatedListener(() {
        expect(control.errors, error);
      });
    });
  });

  test('changing submit requested updates view ', () {
    final control = FormControl<String>();
    expect(control.submitRequested, false);

    bool didChange = false;
    control.registerModelUpdatedListener(() {
      expect(control.submitRequested, true);
      didChange = true;
    });
    control.setSubmitRequested(true);
    expect(didChange, true);
  });

  test('changing enabled status updates view', () {
    final control = FormControl<String>(enabled: true);
    expect(control.enabled, true);

    bool didChange = false;
    control.registerModelUpdatedListener(() {
      expect(control.enabled, false);
      didChange = true;
    });
    control.setEnabled(false);
    expect(didChange, true);
  });

  test('changing touched status updates view', () {
    final control = FormControl<String>();
    expect(control.touched, false);

    bool didChange = false;
    control.registerModelUpdatedListener(() {
      expect(control.touched, true);
      didChange = true;
    });
    control.setTouched(true);
    expect(didChange, true);
  });

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
