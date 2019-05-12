import 'package:equatable/equatable.dart';
import 'package:form_testing/angular_forms.dart';


class NoFreeValidator extends Validator<String> {

  NoFreeValidator(): super([]);

  @override
  Map<String, String> validate(String value) {
    print("validating value, $value");
    if (value == 'Free') {
      return {
        'madErrors': 'Serioulsy, that\'s not how you spell it'
      };
    }
    return null;
  }
}

class NoAtValidator extends Validator<String> {

  final String errorText;

  NoAtValidator([this.errorText = '@ symbol not allowed']) : super([errorText]);

  @override
  Map<String, String> validate(String value) {
    if (value.contains('@')) {
      return {
        'invalidChars': errorText
      };
    }
    return {};
  }
}



