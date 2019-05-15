import 'package:form_testing/forms/forms.dart';



class RequiredValidator extends ValueValidator<String> {
  final String errorText;
  RequiredValidator(this.errorText) : super([errorText]);

  @override
  Map<String, dynamic> validateValue(String value) {
    if (value == null || value.length == 0) {
      return {
        'required': errorText
      };
    }
    return null;
  }

}

/// Returns an error when a string is not a valid email address pattern
/// No error is returned for null or empty strings, these should be handled by required validator
class EmailAddressValidator extends ValueValidator<String> {

  static final emailAddressPattern = new RegExp(
      "^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" +
          "\\@" +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
          "(" +
          "\\." +
          "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
          ")+\$"
  );

  final String errorText;
  EmailAddressValidator(this.errorText): super([errorText]);

  @override
  Map<String, dynamic> validateValue(String value) {
    if (value != null && value.length > 0) {
      if (!emailAddressPattern.hasMatch(value)) {
        return {
          'invalidEmail': errorText
        };
      }
    }
    return null;
  }

}

/// Validates a string against a regex
class RegexValidator extends ValueValidator<String> {
  final RegExp pattern;
  final String errorText;

  RegexValidator(this.pattern, this.errorText) : super([pattern, errorText]);

  @override
  Map<String, dynamic> validateValue(String value) {
    if (value != null && value.length > 0 && !pattern.hasMatch(value)) {
      return {
        'regexFailed': errorText
      };
    }
    return null;
  }
}

/// Validates a non-empty string has a minimum length.
/// To validate empty strings as well, use [RequiredValidator]
class MinLengthValidator extends ValueValidator<String> {
  final int minLength;
  final String errorText;
  MinLengthValidator(this.minLength, this.errorText) : super([minLength, errorText]);

  @override
  Map<String, dynamic> validateValue(String value) {
    if (value != null && value.length > 0 && value.length < minLength) {
      return {
        'minLength': errorText
      };
    }
    return null;
  }

}


