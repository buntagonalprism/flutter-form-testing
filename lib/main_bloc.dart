import 'dart:async';

import 'package:form_testing/forms.dart';
import 'package:equatable/equatable.dart';

abstract class FormKeys {
  static const Text = "text";
  static const Dropdown = "dropdown";
}

class MyFormBloc {
  final _formStreamController = StreamController<FormControl<String>>();
  Stream<FormControl<String>> get form => _formStreamController.stream;

  FormControl<String> formField = FormControl<String>("hello world", [NoAtValidator('blah')]);

  MyFormBloc() {
    delayedAddControl();
  }

  delayedAddControl() async {
    await Future.delayed(Duration());
    _formStreamController.add(formField);
  }

  post() {
    formField.setAutoValidate(true);
  }

}

class NoFreeValidator implements Validator<String> {
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

class NoAtValidator extends Equatable implements Validator<String> {

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