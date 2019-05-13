import 'package:form_testing/forms.dart';


class NoFreeValidator extends ValueValidator<String> {

  NoFreeValidator(): super([]);

  @override
  Map<String, dynamic> validateValue(String value) {
    print("validating value, $value");
    if (value == 'Free') {
      return {
        'madErrors': 'Serioulsy, that\'s not how you spell it'
      };
    }
    return null;
  }
}

class NoAtValidator extends ValueValidator<String> {

  final String errorText;

  NoAtValidator([this.errorText = '@ symbol not allowed']) : super([errorText]);

  @override
  Map<String, String> validateValue(String value) {
    if (value.contains('@')) {
      return {
        'invalidChars': errorText
      };
    }
    return {};
  }
}



