import 'package:flutter_test/flutter_test.dart';
import 'package:form_testing/forms/forms.dart';

void main() {

  final vb = ValidatorSet.builder;

  test('Empty sets equal', () {
    final v1 = vb([]);
    final v2 = vb([]);
    expect(v1, v2);
  });

  test('Configured mock validators equatable', () {
    final v1 = MockValidator('errMsg');
    final v2 = MockValidator('errMsg');
    expect(v1, v2);
  });

  test('Unconfigured single element lists equal', () {
    final v1 = vb([MockValidator()]);
    final v2 = vb([MockValidator()]);
    expect(v1, v2);
  });

  test('Configured single element lists equal', () {
    final v1 = vb([MockValidator('errMsg')]);
    final v2 = vb([MockValidator('errMsg')]);
    expect(v1, v2);
  });

  test('Different single element not equal', () {
    final v1 = vb([MockValidator('errMsg1')]);
    final v2 = vb([MockValidator('errMsg2')]);
    expect(v1 == v2 , false);
  });

  test('Multiple validator equality in different orders', () {
    final v1 = vb([MockValidator(), MockValidator('errMsg'), MockValidator('otherMessage')]);
    final v2 = vb([MockValidator('otherMessage'), MockValidator(), MockValidator('errMsg')]);
    expect(v1, v2);
  });
}

class MockValidator extends Validator<String> {
  final String returnError;
  MockValidator([this.returnError]): super([returnError]);

  @override
  Map<String, dynamic> validate(AbstractControl<String> control) {
    if (returnError != null) {
      return {
        'error': returnError,
      };
    }
    return null;
  }
}

