import 'package:form_testing/forms/forms.dart';
import 'package:form_testing/blocs/sign_up_bloc.dart';
import 'package:form_testing/forms/validators.dart';
import 'package:test/test.dart';

void main() {

  final vsb = ValidatorSet.builder;
  SignUpBloc bloc;
  setUp(() {
    bloc = SignUpBloc();
  });

  test('Email address validators', () {
    expect(bloc.form.controls['email'].validators, vsb([
      EmailAddressValidator('Invalid email address'),
      RequiredValidator('put an email in here'),
    ]));
  });

  test('Password validators', () {
    expect(bloc.form.controls['password'].validators, vsb([
      MinLengthValidator(6, 'Password must be at least 6 characters'),
      RequiredValidator('Yeah you gotta have a password'),
    ]));
  });

  test('Initial confirm validator', () {
    expect(bloc.form.controls['confirmation'].validators, vsb([
      RequiredValidator('This is where the confirmation goes'),
    ]));
  });

  test('Updating password changes confirm validators', () async {
    (bloc.form.controls['password'] as FormControl).onViewValueUpdated('abc123');
    await Future.delayed(Duration());
    expect(bloc.form.controls['confirmation'].validators, vsb([
      RegexValidator(RegExp('abc123'), 'Does not match'),
      RequiredValidator('This is where the confirmation goes'),
    ]));
  });

}

