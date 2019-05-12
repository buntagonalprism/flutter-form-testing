import 'package:form_testing/angular_forms.dart';

import '../lib/validators.dart';
import 'package:test/test.dart';

void main() {

  final vb = ValidatorSet.builder;

  test('Basic Validator function equality', () {
    final v1 = vb([NoAtValidator()]);
    final v2 = vb([NoAtValidator()]);
    print(v1.toString());
    expect(v1, v2);
  });

  test('Configured validator function equality', () {
    final v1 = vb([NoAtValidator('hello world')]);
    final v2 = vb([NoAtValidator('hello world')]);
    expect(v1, v2);
  });

  test('Different validator function inequality', () {
    final v1 = vb([NoAtValidator('Foobar')]);
    final v2 = vb([NoAtValidator('hello world')]);
    print(v1);
    print(v2);
    expect(v1 == v2 , false);
  });

  test('Multiple validator equality in different orders', () {
    final v1 = vb([NoFreeValidator(), NoAtValidator('howdy')]);
    final v2 = vb([NoAtValidator('howdy'), NoFreeValidator()]);
    print(v1);
    expect(v1, v2);
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

  test('Different ordered validator lists equal', () {
    final l1 = [NoAtValidator('foobar'), NoFreeValidator()];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expectListsEqual(l1, l2);
  });

  test('Same ordered validator lists equal', () {
    final l1 = [NoFreeValidator(), NoAtValidator('foobar')];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expectListsEqual(l1, l2);
  });

  test('Different validator lists not equal', () {
    final l1 = [NoFreeValidator(), NoAtValidator('foobaz')];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expect(() => expectListsEqual(l1, l2), throwsA(TypeMatcher<String>()));
  });

  test('Different validator lists lengths not equal', () {
    final l1 = [NoFreeValidator()];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expect(() => expectListsEqual(l1, l2), throwsA(TypeMatcher<String>()));
  });

  test('Dart native list equality checking', (){
    final l1 = [NoFreeValidator(), NoAtValidator('foobar')];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expect(l1, l2);
  });

  test('Dart unordered list equality checking fails', (){
    final l1 = [NoAtValidator('foobar'), NoFreeValidator()];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expect(l1, l2);
  });

  test('Dart unordered list equality checking using hashcode sort', (){
    final l1 = [NoAtValidator('foobar'), NoFreeValidator()];
    final l2 = [NoFreeValidator(), NoAtValidator('foobar')];
    expectUnorderedListsEqual(l1, l2);
  });
}

expectUnorderedListsEqual<T>(List<T> actualList, List<T> expectedList) {
  actualList.sort((a, b) => a.hashCode.compareTo(b.hashCode));
  expectedList.sort((a, b) => a.hashCode.compareTo(b.hashCode));
  expect(actualList, expectedList);
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
