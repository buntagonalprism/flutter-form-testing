
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_testing/forms.dart';


class ControlledTextField extends StatefulWidget {

  final InputDecoration decoration;
  final FormControl<String> control;
  ControlledTextField(this.control, [this.decoration]);

  @override
  _ControlledTextFieldState createState() => new _ControlledTextFieldState();

}

class _ControlledTextFieldState extends State<ControlledTextField> {

  InputDecoration decoration;
  final controller = TextEditingController();
  final focus = FocusNode();
  bool focused = false;

  @override
  void initState() {
    super.initState();
    decoration = widget.decoration ?? InputDecoration();
    controller.text = widget.control.value;
    widget.control.registerModelUpdatedListener((Map<ModelUpdateType, dynamic> updates) {
      if (updates.containsKey(ModelUpdateType.Value)) {
        controller.text = updates[ModelUpdateType.Value];
      }
    });
    focus.addListener(() {
      // Mark field as touched and trigger a rebuild when focus is lost
      if (focused && !focus.hasFocus) {
        widget.control.setDisplayErrors(true);
      }
      focused = focus.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focus,
      controller: controller,
      onChanged: (value) => widget.control.onViewValueUpdated(value),
      decoration: decoration.copyWith(errorText: errorText),
    );
  }

  String get errorText {
    if (widget.control.displayErrors && widget.control.enabled) {
      return widget.control.errors.length > 0 ? widget.control.errors.values.map((error) => error.toString()).join('\n') : null;
    } else {
      return null;
    }
  }
}


typedef FieldBuilder<T> = Widget Function(T state, ValueChanged<T> onChange);


