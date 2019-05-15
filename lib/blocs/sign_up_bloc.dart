import 'package:form_testing/forms/forms.dart';
import 'package:form_testing/data/sign_up.dart';
import 'package:form_testing/forms/validators.dart';

abstract class FormKeys {
  static const Text = "text";
  static const Dropdown = "dropdown";
}


class SignUpBloc {

  FormControl<String> _emailControl;
  FormControl<String> _passwordControl;
  FormControl<String> _confirmControl;

  FormGroup<SignUp> form;

  SignUpBloc() {
    final vsb = ValidatorSet.builder;
    final emailRequiredValidator = RequiredValidator('put an email in here');
    final emailValidValidator = EmailAddressValidator('Invalid email address');
    final emailValidators = vsb([emailRequiredValidator, emailValidValidator]);
    _emailControl = FormControl<String>(initialValue: '', validators: emailValidators);

    final passwordRequiredValidator = RequiredValidator('Yeah you gotta have a password');
    final passwordLengthValidator = MinLengthValidator(6, 'Password must be at least 6 characters');
    final passwordValidators = vsb([passwordRequiredValidator, passwordLengthValidator]);
    _passwordControl = FormControl<String>(validators: passwordValidators);

    final confirmRequiredValidator = RequiredValidator('This is where the confirmation goes');
    _passwordControl.valueUpdated.listen((password) {
      final confirmMatchesValidator = RegexValidator(RegExp(password), 'Does not match');
      final confirmValidators = vsb([confirmRequiredValidator, confirmMatchesValidator]);
      _confirmControl.setValidators(confirmValidators);
    });
    final confirmValidators = vsb([confirmRequiredValidator]);
    _confirmControl = FormControl<String>(initialValue: '', validators: confirmValidators);

    form = FormGroup<SignUp>({
      'email': _emailControl,
      'password': _passwordControl,
      'confirmation': _confirmControl
    }, SignUp.fromJson);

  }


  post() {}

}


class MyDataClass {
  String textField;
  String dropdownField;
}