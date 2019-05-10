
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_testing/forms.dart';

class ControlledTextField extends StatefulWidget {
  final FormControl<String> control;
  final InputDecoration decoration;
  ControlledTextField({
    @required this.control,
    this.decoration,
  }) : assert(control != null);

  @override
  _ControlledTextFieldState createState() => _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {

  TextEditingController _textController;
  InputDecoration _decoration;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.control.value);
    _decoration = widget.decoration ?? InputDecoration();
  }

  @override
  Widget build(BuildContext context) {
    return FormControlBuilder<String>(
      control: widget.control,
      builder: (FormControlState<String> state, ValueChanged<String> onChange) {
        print("Is this building");
        return TextField(
            controller: _textController,
            onChanged: onChange,
            decoration: _decoration.copyWith(errorText: state.error)
        );
      },
    );
  }
}




class FormControlBuilder<T> extends StatelessWidget {

  final FormControl<T> control;
  final FieldBuilder<T> builder;
  FormControlBuilder({@required this.control, @required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: control.stateStream,
      initialData: control.state,
      builder: (context, AsyncSnapshot<FormControlState<T>> stateSnapshot) {
        return builder(stateSnapshot.requireData, (T newValue) => control.setValue(newValue));
      },
    );
  }
}


typedef FieldBuilder<T> = Widget Function(FormControlState<T> state, ValueChanged<T> onChange);


