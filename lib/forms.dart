
import 'dart:async';

import 'package:form_testing/angular_forms.dart';
import 'package:meta/meta.dart';

import 'validators.dart';

class FormControlState<T> {
  FormControlState({@required this.value, this.error});
  final T value;
  final String error;
}

typedef ValidatorFn<T> = Map<String, dynamic> Function(T data);

class FormControl<T> {

  FormControl([T initialValue, List<Validator<T>> validators, bool autoValidate]) {
    _value = initialValue;
    _validators = validators; //(validators);
    _autoValidate = autoValidate == true;
    validate();
    _updateState();
  }

//  _initValidators(List<Validator<T>> validators) {
//    Validators = validators ?? [];
//    for (var validator in Validators) {
//      if (validator is AsyncValidator) {
//        _asyncValidators.add(validator);
//      } else {
//        _validators.add(validator);
//      }
//    }
//  }

//  List<Validator> Validators;
  List<Validator<T>> _validators = [];
//  List<AsyncValidator<T>> _asyncValidators = [];

  bool _autoValidate;
  bool _pending;

  bool get pending => _pending;
  List<Validator> get validators => _validators;

  setAutoValidate(bool autoValidate) {
    if (!_autoValidate && autoValidate) {
      validate();
      _notify();
    }
    _autoValidate = autoValidate;
  }


  T _value;
  T get value => _value;
  setValue(T newValue) {
    print("New value: $newValue");
    _value = newValue;
    if (_autoValidate) {
      validate();
    }
    _updateState();
    _notify();
  }
  final _errors = Map<String, String>();
  String get errors => _errors.length > 0 ? _errors.values.join('\n') : null;

  Future validate() async {
    _errors.clear();
    for (var validator in _validators) {
      _errors.addAll(validator.validate(_value) ?? {});
    }
    _updateState();
    _notify();
//    if (_asyncValidators.length > 0) {
//      _pending = true;
//      List<Map<String, dynamic>> errors = await Future.wait(_asyncValidators.map((validator) => validator.validateAsync(_value)));
//      _pending = false;
//      for (var error in errors) {
//        _errors.addAll(error);
//      }
//
//    }
  }

  bool get isValid => _errors.length == 0;

  _updateState() {
    _currentState = FormControlState(value: _value, error: errors);
  }

  _notify() {
    _stateStreamController.add(_currentState);
  }

  FormControlState<T> _currentState;
  final _stateStreamController = StreamController<FormControlState<T>>.broadcast();
  Stream<FormControlState<T>> get stateStream => _stateStreamController.stream;
  FormControlState<T> get state => _currentState;
}

class FormArray<T> {
  final List<FormControl<T>> controls;
  FormArray([this.controls]);

  setAutoValidate(bool autoValidate) {
    for (var control in controls) {
      control.setAutoValidate(autoValidate);
    }
  }

  addControl(FormControl<T> control, [int index])  {

    controls.add(control);
  }

  removeControl(int index) {
    controls.removeAt(index);
  }
}

class FormGroupControl<GroupType, ControlType> {
  final String key;
  final FormControl<ControlType> control;
  final ControlChange<GroupType, ControlType> onChange;
  FormGroupControl({this.key, this.control, this.onChange});
}

typedef ControlChange<GroupType, ControlType> = GroupType Function(GroupType group, ControlType value);

class FormGroup<T> {
  final _controls = Map<String, FormGroupControl<T, dynamic>>();
  FormGroup(T initialValue, List<FormGroupControl<T, dynamic>> controls) {
    for (var control in controls) {
      _controls[control.key] = control;
    }
  }

  FormControl getControl(String controlName) {
    return _controls[controlName].control;
  }
}

class FormBuilder {
  FormGroupControl<GroupType, ControlType> control<GroupType, ControlType>({String key, ControlType initialValue, List<Validator<ControlType>> validators, ControlChange<GroupType, ControlType> onChange}) {
    return FormGroupControl<GroupType, ControlType>(
      key: key,
      control: FormControl(initialValue, validators),
      onChange: onChange
    );
  }

  FormGroup group<GroupType>({GroupType initialValue, List<FormGroupControl<GroupType, dynamic>> controls}) {
    return FormGroup<GroupType>(initialValue, controls);
  }
}