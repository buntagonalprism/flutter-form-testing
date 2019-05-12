import 'package:flutter/material.dart';
import 'package:form_testing/angular_forms.dart';
import 'package:form_testing/form_widgets.dart';
import 'package:form_testing/forms.dart';
import 'package:form_testing/main_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MyFormBloc _bloc;

  List<DropdownMenuItem<String>> items;

  FormControl<String> ddControl;

  @override
  void initState() {
    super.initState();
    _bloc = MyFormBloc();
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: _bloc.form,
              builder: _formBuilder,
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'A second field'
              ),
            )
//            FormControlBuilder(
//              control: ddControl,
//              builder: (FormControlState<String> state, ValueChanged<String> onChange) {
//                print("Building with value ${state.value}");
//                return InputDecorator(
//                  decoration: InputDecoration(
//                    labelText: 'Choose Option',
//                    errorText: state.error,
//                  ),
//                  isEmpty: false,
//                  child: DropdownButton(
//                    isDense: true,
//                    value: state.value,
//                    items: items,
//                    onChanged: onChange
//                  ),
//                );
//              },
//            ),
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

  Widget _formBuilder(BuildContext context, AsyncSnapshot<Control<String>> control) {
    if (control.hasData) {
      return ControlledTextField(
        control.data,
        InputDecoration(
          icon: Icon(Icons.person),
          hintText: 'What do people call you?',
          labelText: 'Name *',
        ),
      );
    } else {
      return Text(
          "Loading"
      );
    }
  }
}

