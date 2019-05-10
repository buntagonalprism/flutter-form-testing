
import 'dart:async';

import 'package:meta/meta.dart';

class FormControlState<T> {
  FormControlState({@required this.value, this.error});
  final T value;
  final String error;
}

typedef ValidatorFn<T> = Map<String, String> Function(T data);

abstract class _BaseValidator<T> {}

abstract class Validator<T> implements _BaseValidator<T> {
  Map<String, dynamic> validate(T value);
}

abstract class AsyncValidator<T> implements _BaseValidator<T> {
  Future<Map<String, dynamic>> validateAsync(T value);
}

class FormControl<T> {

  FormControl([T initialValue, List<_BaseValidator<T>> validators, bool autoValidate]) {
    _value = initialValue;
    _initValidators(validators);
    _autoValidate = autoValidate == true;
    validate();
    _updateState();
  }

  _initValidators(List<_BaseValidator<T>> validators) {
    _baseValidators = validators ?? [];
    for (var validator in _baseValidators) {
      if (validator is AsyncValidator) {
        _asyncValidators.add(validator);
      } else {
        _validators.add(validator);
      }
    }
  }

  List<_BaseValidator> _baseValidators;
  List<Validator<T>> _validators = [];
  List<AsyncValidator<T>> _asyncValidators = [];

  bool _autoValidate;
  bool _pending;

  bool get pending => _pending;
  List<_BaseValidator> get validators => _baseValidators;

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
    if (_asyncValidators.length > 0) {
      _pending = true;
      List<Map<String, dynamic>> errors = await Future.wait(_asyncValidators.map((validator) => validator.validateAsync(_value)));
      _pending = false;
      for (var error in errors) {
        _errors.addAll(error);
      }
      _updateState();
      _notify();
    }
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

class FormGroup {
  final Map<String, FormControl> controls;
  FormGroup(this.controls);

  FormControl getControl(String controlName) {
    return controls[controlName];
  }
}