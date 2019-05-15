import 'package:flutter_test/flutter_test.dart';

class MyTestClass {
  ValidatorFn getValidator(String someValue){
    return (String input) {
      if (input.contains(someValue)) {
        return "invalid input, contains $someValue";
      }
      return null;
    };
  }
}

typedef String ValidatorFn(String input);

void main() {
  test('Functions with the same body are not equal', () async {
    final sut = MyTestClass();
    expect(sut.getValidator('hello') == sut.getValidator('hello'), false);
  });
}