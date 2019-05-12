import 'package:form_testing/angular_forms.dart';
import 'package:form_testing/main_bloc.dart';
import 'package:form_testing/validators.dart';
import 'package:test/test.dart';

void main() {

  final vb = ValidatorSet.builder;

  test('Email address validators', () async {
    final bloc = MyFormBloc();
    Control<String> control = await bloc.form.first;
    expect(control.validator, vb([NoAtValidator('blah')]));
  });


}

