import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:form_testing/flutter_forms/form_widgets.dart';
import 'package:form_testing/forms/forms.dart';
import 'package:form_testing/blocs/sign_up_bloc.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();

class SignUpScreen extends StatefulWidget {
  SignUpScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  SignUpBloc _bloc;

  List<DropdownMenuItem<String>> items;

  FormControl<String> ddControl;

  bool obscurePassword = true;
  bool obscureConfirmation = true;

  @override
  void initState() {
    super.initState();
    _bloc = SignUpBloc();
    items =  <String>['One', 'Two', 'Free', 'Four']
        .map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ControlledTextField(
                _bloc.form.getControl('email'),
                decoration: InputDecoration(
                    labelText: 'Email Address'
                ),
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ControlledTextField(
                _bloc.form.getControl('password'),
                decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    )
                ),
                obscureText: obscurePassword,
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ControlledTextField(
                _bloc.form.getControl('confirmation'),
                decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirmation ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => obscureConfirmation = !obscureConfirmation),
                    )
                ),
                obscureText: obscureConfirmation,
              ),
            ),
            RaisedButton(
              child: Text('SIGN UP'),
              onPressed: () {
                _bloc.form.setSubmitRequested(true);
                bool valid = _bloc.form.valid;
                if (valid) {
                  showSnackBar('all fields valid');
                  print(_bloc.form.value);
                  print(json.encode(_bloc.form.value));
                } else {
                  showSnackBar('there are invalid fields');
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bloc.post,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  void showSnackBar(String msg) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
  }
}

