
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

enum ModelUpdateType {
  Value,
  Errors,
  State
}

typedef ViewNotifier(List<ModelUpdateType> updates);

abstract class AbstractControl<T> {

  T _value;
  final _errors = Map<String, dynamic>();

  ViewNotifier _viewNotifier;
  bool _enabled = true;
  bool _autoValidate = false;
  ValidatorSet<T> _validators = ValidatorSet<T>([]);

  Map<String, dynamic> get errors => _errors;
  bool get enabled => _enabled;
  bool get autoValidate => _autoValidate;
  bool get isValid => _errors.length == 0;

  /// Get the value of the control. If this control is disabled, the value will be returned as null
  T get value;
  Stream<T> viewValueUpdated;
  Stream<Map<String, dynamic>> errorsUpdated;


  /// Should only be used by the view input field which is binding to this control. The
  /// [ViewNotifier] allows the view to receive updates when external logic modifies the model value
  /// of this control. To respond to user input, listen to the [viewValueUpdated] stream instead.
  registerModelUpdatedListener(ViewNotifier notifier) {
    _viewNotifier = notifier;
  }

  /// Should only be used by view input fields when the user updates the value within the view.
  /// Results in [viewValueUpdates] emitting a new event. To programmatically change the value in
  /// the view, use the [setValue] method instead.
  onViewValueUpdated(T newValue);

  /// Update the view with a new value. Results in the [ViewNotifier] informing the view that it
  /// needs to rebuild with the new value.
  setValue(T newValue);

  /// Whether this control should perform validation every time the value changes. This setting
  /// affects both when the user changes the value in the view, and when the value is changed using
  /// [setValue]
  setAutoValidate(bool autoValidate);

  /// Manually run a validation of the current value using the current validators and return the
  /// errors. When [notifyView] is true (the default), the control is updated with these errors and
  /// the view is notified. If [notifyView] is false then the errors are only calculated not stored
  /// and the view is not notified.
  Map<String, dynamic> validate([bool notifyView = true]) {
    final errors = _validators(this);
  }

  /// Update the validators that should be run when this control is validated.
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
    if (_autoValidate) {
      validate();
    }
  }

  setEnabled(bool enabled) {
    final enabledDidChange = _enabled != enabled;
    if (enabledDidChange) {
      _enabled = enabled;
      _viewNotifier([ModelUpdateType.State]);
    }
  }
}



class FormControl<T> extends AbstractControl<T> {
  FormControl({T initialValue, bool autoValidate, ValidatorSet validators}) {
    if (initialValue != null) {
      _value = initialValue;
    }
    if (validators != null) {
      _validators = validators;
    }
    _autoValidate = autoValidate == true;
    if (_autoValidate) {
      validate();
    }
  }
}











/// Base class for performing validation on an control.
abstract class Validator<T> extends Equatable {
  Validator(List props) : super(props);
  Map<String, dynamic> validate(AbstractControl<T> control);

  @override
  String toString() => props.isNotEmpty ? (runtimeType.toString() + ":" + props.toString()) : super.toString();
}

/// Interface for validators that only care about the value of the control.
abstract class ValueValidator<T> extends Validator<T> {
  ValueValidator(List props) : super(props);

  Map<String, dynamic> validate(AbstractControl<T> control) {
    return validateValue(control.value);
  }

  Map<String, dynamic> validateValue(T value);
}


class ValidatorSet<T> {
  List<Validator<T>> _validators;
  List<Validator<T>> get validators => _validators;

  static ValidatorSet<T> builder<T>(List<Validator<T>> validators) {
    return ValidatorSet(validators);
  }

  ValidatorSet(List<Validator<T>> validators) {
    validators.sort((a, b) => a.hashCode.compareTo(b.hashCode));
    this._validators = validators;
  }

  Map<String, dynamic> call(AbstractControl<T> control) {
    final errors = Map<String, dynamic>();
    for (var validator in _validators) {
      errors.addAll(validator.validate(control));
    }
    return errors;
  }

  @override
  String toString() {
    return "Validators: $_validators";
  }

  @override
  bool operator == (Object other) {
    return identical(this, other) ||
        (other is ValidatorSet &&
            runtimeType == other.runtimeType &&
            _validatorsEqual(other)
        );
  }

  bool _validatorsEqual(ValidatorSet other) {
    if (validators.length != other.validators.length) {
      return false;
    }
    for (int i = 0; i < validators.length; i++) {
      if (validators[i] != other.validators[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    int hashCode = 0;
    validators.forEach((v) => hashCode = hashCode ^ v.hashCode);
    return hashCode;
  }
}

typedef Deserializer<T> = T Function(Map<String, dynamic> source);

class FormGroup<T> extends AbstractControl<T> {

  final Deserializer<T> deserializer;
  final Map<String, FormControl> controls;

  FormGroup({@required this.deserializer, @required this.controls, bool autoValidate = false}) {
    this._autoValidate = autoValidate == true;
  }

  FormControl getControl(String controlName) {
    return controls[controlName];
  }
}

class FormArray<T> extends AbstractControl<List<T>> {

}

class FormBuilder {


  FormGroup group<GroupType>({GroupType initialValue, List<FormGroupControl<GroupType, dynamic>> controls}) {
    return FormGroup<GroupType>(initialValue, controls);
  }
}