
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_testing/forms/forms.dart';


class ControlledTextField extends StatefulWidget {

  final bool obscureText;
  final TextInputType textInputType;
  final InputDecoration decoration;
  final TextInputAction textInputAction;
  final FormControl<String> control;
  ControlledTextField(this.control, {
    this.decoration,
    this.textInputType,
    this.obscureText,
    this.textInputAction,
  });

  String get errorText {
    if (control.submitRequested && control.enabled) {
      return control.errors.length > 0 ? control.errors.values.map((error) => error.toString()).join('\n') : null;
    } else {
      return null;
    }
  }

  @override
  _ControlledTextFieldState createState() => new _ControlledTextFieldState();
}

class _ControlledTextFieldState extends State<ControlledTextField> {

  final controller = TextEditingController();
  final focus = FocusNode();
  bool focused = false;

  @override
  void initState() {
    super.initState();
    controller.text = widget.control.value;
    widget.control.registerModelUpdatedListener((List<ModelUpdate> updates) {
      if (updates.contains(ModelUpdate.Value)) {
        controller.text = widget.control.value;
        if (updates.length > 0) {
          _redraw();
        }
      } else {
        _redraw();
      }
    });
    focus.addListener(() {
      // Mark field as touched and trigger a rebuild when focus is lost
      if (focused && !focus.hasFocus) {
        widget.control.setSubmitRequested(true);
      }
      focused = focus.hasFocus;
    });
  }

  _redraw() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.obscureText ?? false,
      keyboardType: widget.textInputType,
      focusNode: focus,
      controller: controller,
      enabled: widget.control.enabled,
      textInputAction: widget.textInputAction,
      onChanged: (value) => widget.control.onViewValueUpdated(value),
      decoration: (widget.decoration ?? InputDecoration()).copyWith(errorText: widget.errorText),
    );
  }

}


typedef FieldBuilder<T> = Widget Function(T state, ValueChanged<T> onChange);


