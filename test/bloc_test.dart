import 'package:form_testing/forms.dart';
import 'package:form_testing/main_bloc.dart';
import 'package:test/test.dart';

void main() {
  test('No-argument validator equality', () {
    final v1 = NoAtValidator();
    final v2 = NoAtValidator();
    expect(v1, v2);
  });

  test('Configured validator equality', () {
    final v1 = NoAtValidator('hello world');
    final v2 = NoAtValidator('hello world');
    expect(v1, v2);
  });

  test('Email address validators', () async {
    final bloc = MyFormBloc();
    FormControl<String> control = await bloc.form.first;
    expectListsEqual(control.validators, [NoAtValidator('blah')]);
  });

  test('Default no at validator', () {
    final defaultValidator = NoAtValidator();
    Map<String, dynamic> errors = defaultValidator.validate('hahah @ you');
    expect(errors, {'invalidChars': '@ symbol not allowed'});
    errors = defaultValidator.validate('all good');
    expect(errors, {});
  });

  test('Configured no at validator', () {
    final defaultValidator = NoAtValidator('hello world');
    Map<String, dynamic> errors = defaultValidator.validate('hahah @ you');
    expect(errors, {'invalidChars': 'hello world'});
    errors = defaultValidator.validate('all good');
    expect(errors, {});
  });
}

expectListsEqual<T>(List<T> actualList, List<T> expectedList) {
  if (expectedList.length != actualList.length) {
    throw "Expected length ${expectedList.length} does not match actual length ${actualList.length}";
  }
  for (var expected in expectedList) {
    if (!actualList.contains(expected)) {
      throw 'Expected item of type ${expected.runtimeType}, with value: $expected not present in actual list';
    }
  }
  for (var actual in actualList) {
    if (!expectedList.contains(actual)) {
      throw 'Actual item of type ${actual.runtimeType}, with value: $actual not present in expected list';
    }
  }
}