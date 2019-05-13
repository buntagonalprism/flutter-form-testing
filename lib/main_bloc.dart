import 'dart:async';

import 'package:form_testing/forms.dart';
import 'package:form_testing/validators.dart';

abstract class FormKeys {
  static const Text = "text";
  static const Dropdown = "dropdown";
}


class MyFormBloc {
  final _formStreamController = StreamController<FormControl<String>>();
  Stream<FormControl<String>> get form => _formStreamController.stream;



  MyFormBloc() {
    delayedAddControl();
  }

  delayedAddControl() async {
    await Future.delayed(Duration());
    final vb = ValidatorSet.builder;
    final val = vb([NoAtValidator('blah')]);
    FormControl<String> formField = FormControl<String>(initialValue: "hello@world", validators: val);
    _formStreamController.add(formField);
  }

  post() {}

}


class MyDataClass {
  String textField;
  String dropdownField;
}