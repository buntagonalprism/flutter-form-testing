import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms/forms.dart';
import 'package:mockito/mockito.dart';

class ControlMock extends Mock implements FormControl {}



void main() {

  final vsb = ValidatorSet.builder;

  ControlMock firstMock;
  ControlMock secondMock;
  ControlMock thirdMock;
  Map<String, AbstractControl> controls;

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
    controls = {
      FIRST_KEY: firstMock,
      SECOND_KEY: secondMock,
      THIRD_KEY: thirdMock
    };
  });

  test('Get controller by key', () {
    final group = FormGroup<DummyData>(controls, DummyData.fromJson);
    expect(group.getControl(FIRST_KEY), firstMock);
    expect(group.getControl(SECOND_KEY), secondMock);
    expect(group.getControl(THIRD_KEY), thirdMock);
  });

  group('Initialisation passes down', () {

    test('value when supplied', () {
      final data = DummyData.fromJson({FIRST_KEY: 'abc', SECOND_KEY: 'qwe', THIRD_KEY: '123'});
      FormGroup<DummyData>(controls, DummyData.fromJson, initialValue: data);
      verify(firstMock.setValue('abc')).called(1);
      verify(secondMock.setValue('qwe')).called(1);
      verify(thirdMock.setValue('123')).called(1);
    });

    test('no value when not supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson);
      verifyNever(firstMock.setValue(any));
      verifyNever(secondMock.setValue(any));
      verifyNever(thirdMock.setValue(any));
    });

    test('enabled status when supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson, enabled: false);
      verify(firstMock.setEnabled(false)).called(1);
      verify(secondMock.setEnabled(false)).called(1);
      verify(thirdMock.setEnabled(false)).called(1);
    });

    test('no enabled status when not supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson);
      verifyNever(firstMock.setEnabled(any));
      verifyNever(secondMock.setEnabled(any));
      verifyNever(thirdMock.setEnabled(any));
    });

    test('display errors status when supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson, displayErrors: true);
      verify(firstMock.setDisplayErrors(true)).called(1);
      verify(secondMock.setDisplayErrors(true)).called(1);
      verify(thirdMock.setDisplayErrors(true)).called(1);
    });

    test('no display error status when not supplied', () {
      FormGroup<DummyData>(controls, DummyData.fromJson);
      verifyNever(firstMock.setDisplayErrors(any));
      verifyNever(secondMock.setDisplayErrors(any));
      verifyNever(thirdMock.setDisplayErrors(any));
    });
  });



  group('Get value:', () {
    test('Collects data from all children', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      when(firstMock.value).thenReturn('a');
      when(secondMock.value).thenReturn('b');
      when(thirdMock.value).thenReturn('c');
      DummyData data = group.value;
      expect(data.toJson(), {FIRST_KEY: 'a', SECOND_KEY: 'b', THIRD_KEY: 'c'});
    });

    test('Disabled children have null value', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      when(firstMock.enabled).thenReturn(false);
      when(firstMock.value).thenReturn('a');
      when(secondMock.enabled).thenReturn(false);
      when(secondMock.value).thenReturn('b');
      when(thirdMock.value).thenReturn('c');
      DummyData data = group.value;
      expect(data.toJson(), {FIRST_KEY: null, SECOND_KEY: null, THIRD_KEY: 'c'});
    });
  });

  group('Updates are passed down to all children', () {

    test('Value', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      final data = DummyData.fromJson({FIRST_KEY: 'tyu', SECOND_KEY: 'ikm', THIRD_KEY: 'dfg'});
      group.setValue(data);
      verify(firstMock.setValue('tyu')).called(1);
      verify(secondMock.setValue('ikm')).called(1);
      verify(thirdMock.setValue('dfg')).called(1);
    });

    test('displayErrors status', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      verifyNever(firstMock.setDisplayErrors(any));
      group.setDisplayErrors(false);
      verify(firstMock.setDisplayErrors(false)).called(1);
      verify(secondMock.setDisplayErrors(false)).called(1);
      verify(thirdMock.setDisplayErrors(false)).called(1);
    });

    test('enabled status', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      verifyNever(firstMock.setEnabled(any));
      group.setEnabled(true);
      verify(firstMock.setEnabled(true)).called(1);
      verify(secondMock.setEnabled(true)).called(1);
      verify(thirdMock.setEnabled(true)).called(1);
    });
  });

  group('Validation', () {
    test('Default empty validator set', () {
      final emptyValidatorSet = ValidatorSet<DummyData>([]);
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      expect(group.validators, emptyValidatorSet);
    });

    test('Initial validators stored', () {
      final validators = vsb([MockValidator({'oops':'an error'})]);
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: validators);
      expect(group.validators, validators);
    });

    test('Updated validators are stored', () {
      final group = FormGroup<DummyData>(controls, DummyData.fromJson);
      final validators = vsb([MockValidator({'oops':'an error'})]);
      group.setValidators(validators);
      expect(group.validators, validators);
    });

    test('Getting errors runs group validator', () {
      final validator = MockValidator({'oops':'an error'});
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      when(firstMock.value).thenReturn('123');
      when(secondMock.value).thenReturn('456');
      when(thirdMock.value).thenReturn('789');
      final errors = group.errors;
      expect(errors, {'oops':'an error'});
      expect(validator.calledWithValues[0].first, '123');
      expect(validator.calledWithValues[0].second, '456');
      expect(validator.calledWithValues[0].third, '789');
    });

    test('Getting errors combines all child errors keyed by their control Id', () {
      final validator = MockValidator({'oops':'This is a group error'});
      final group = FormGroup<DummyData>(controls, DummyData.fromJson, validators: vsb([validator]));
      expect(validator.calledWithValues, isEmpty);
      when(firstMock.errors).thenReturn({});
      when(secondMock.errors).thenReturn({'secondErr':'yes'});
      when(thirdMock.errors).thenReturn({'thirdErrOne': 'also', 'thirdErrTwo':'another'});
      final errors = group.errors;
      expect(errors, {
        'oops': 'This is a group error',
        'controlErrors': {
          SECOND_KEY: {
            'secondErr': 'yes'
          },
          THIRD_KEY: {
            'thirdErrOne': 'also',
            'thirdErrTwo': 'another'
          }
        }
      });
    });
  });
}

const FIRST_KEY = 'first';
const SECOND_KEY = 'second';
const THIRD_KEY = 'third';

class DummyData {
  String first;
  String second;
  String third;
  Map<String, dynamic> toJson() {
    return {
      'first': first,
      'second': second,
      'third': third
    };
  }
  static DummyData fromJson(Map<String, dynamic> json) {
    return DummyData()
        ..first = json['first']
        ..second = json['second']
        ..third = json['third'];
  }
}

class MockValidator extends Validator<DummyData> {
  final Map<String, dynamic> returnErrors;
  MockValidator([this.returnErrors]): super([returnErrors]);

  final List<DummyData> calledWithValues = List<DummyData>();

  @override
  Map<String, dynamic> validate(AbstractControl<DummyData> control) {
    calledWithValues.add(control.value);
    return returnErrors;
  }
}
