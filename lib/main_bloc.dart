import 'dart:async';

//import 'package:form_testing/forms.dart';
import 'package:form_testing/angular_forms.dart';
import 'package:form_testing/validators.dart';

abstract class FormKeys {
  static const Text = "text";
  static const Dropdown = "dropdown";
}


class MyFormBloc {
  final _formStreamController = StreamController<Control<String>>();
  Stream<Control<String>> get form => _formStreamController.stream;



  MyFormBloc() {
    delayedAddControl();
  }

  delayedAddControl() async {
    await Future.delayed(Duration());
    final vb = ValidatorSet.builder;
    final val = vb([NoAtValidator('blah')]);
    Control<String> formField = Control<String>("hello@world", val);
    _formStreamController.add(formField);
  }

  post() {}

}


class MyDataClass {
  String textField;
  String dropdownField;
}