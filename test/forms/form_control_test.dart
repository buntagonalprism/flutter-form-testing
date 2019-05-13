import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms.dart';

void main() {
  final vb = ValidatorSet.builder;
  MockValidator withErrorValidator;
  MockValidator noErrorValidator;
  Map<String, dynamic> error;
  List<Map<ModelUpdateType, dynamic>> modelUpdates;

  setUp(() {
    error = {'ohNo':'an error occured'};
    withErrorValidator = MockValidator(error);
    noErrorValidator = MockValidator(null);
    modelUpdates = List<Map<ModelUpdateType, dynamic>>();
  });


  group('Initialisation', () {
    test('Value and validators stored in control', () {
      final control = FormControl(initialValue: 'surprise', validators: vb([noErrorValidator]));
      expect(control.value, 'surprise');
      expect(control.validators, vb([withErrorValidator]));
    });
    test('Validators run against initial value', () {
      final control = FormControl(initialValue: 'abc', validators: vb([withErrorValidator]));
      expect(withErrorValidator.calledWithValues, ['abc']);
      expect(control.errors, error);
    });
  });


  group('view value changes', () {
    test('Update control value', () {
      final control = FormControl<String>(initialValue: 'initial');
      expect(control.value, 'initial');
      control.onViewValueUpdated('updated');
      expect(control.value, 'updated');
    });

    test('runs validation', () {
      final control = FormControl<String>(initialValue: 'initial', validators: vb([noErrorValidator]));
      control.onViewValueUpdated('foobar');
      expect(noErrorValidator.calledWithValues, ['initial', 'foobar']);
    });

    test('update value listeners', () {
      final control = FormControl<String>();
      expect(control.valueUpdated, emitsInOrder([
        'xyz'
      ]));
      control.onViewValueUpdated('xyz');
    });

    test('updates view with errors', () {
      final control = FormControl<String>(validators: vb([withErrorValidator]));
      control.registerModelUpdatedListener((updates) => modelUpdates.add(updates));
      control.onViewValueUpdated('abc');
      expect(modelUpdates, [{
        ModelUpdateType.Errors: error
      }]);
      expect(control.errors, error);
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
      control.registerModelUpdatedListener((updates) => modelUpdates.add(updates));
      control.setValue('abc');
      expect(modelUpdates, [{
        ModelUpdateType.Value: 'abc',
        ModelUpdateType.Errors: error,
      }]);
      expect(control.errors, error);
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
      control.registerModelUpdatedListener((updates) => modelUpdates.add(updates));
      control.setValidators(vb([withErrorValidator]));
      expect(modelUpdates, [{
        ModelUpdateType.Errors: error,
      }]);
    });
  });

  test('changing display errors updates view ', () {
    final control = FormControl<String>();
    control.registerModelUpdatedListener((updates) => modelUpdates.add(updates));
    expect(control.displayErrors, false);
    control.setDisplayErrors(true);
    expect(control.displayErrors, true);
    expect(modelUpdates, [{
      ModelUpdateType.State: true
    }]);

    // Set back to false
    modelUpdates.clear();
    control.setDisplayErrors(false);
    expect(control.displayErrors, false);
    expect(modelUpdates, [{
      ModelUpdateType.State: true,
    }]);
  });

  test('changing enabled status updates view', () {
    final control = FormControl<String>();
    control.registerModelUpdatedListener((updates) => modelUpdates.add(updates));
    expect(control.enabled, true);
    control.setEnabled(false);
    expect(control.enabled, false);
    expect(modelUpdates, [{
      ModelUpdateType.State: true,
    }]);

    // Enable again
    modelUpdates.clear();
    control.setEnabled(true);
    expect(control.enabled, true);
    expect(modelUpdates, [{
      ModelUpdateType.State: true,
    }]);  });

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

