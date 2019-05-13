import 'package:form_testing/forms.dart';
import 'package:form_testing/main_bloc.dart';
import 'package:form_testing/validators.dart';
import 'package:test/test.dart';

void main() {

  final vb = ValidatorSet.builder;

  test('Email address validators', () async {
    final bloc = MyFormBloc();
    FormControl<String> control = await bloc.form.first;
    expect(control.validators, vb([NoAtValidator('blah')]));
  });


}

