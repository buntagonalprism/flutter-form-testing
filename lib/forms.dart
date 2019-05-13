
import 'dart:async';

import 'package:equatable/equatable.dart';

enum ModelUpdateType {
  Value,
  Errors,
  State
}

typedef ViewNotifier(Map<ModelUpdateType, dynamic> updates);

abstract class AbstractControl<T> {

  T _value;
  final _errors = Map<String, dynamic>();
  final _valueController = StreamController<T>.broadcast();

  ViewNotifier _viewNotifier;
  bool _enabled = true;
  bool _displayErrors = false;
  ValidatorSet<T> _validators = ValidatorSet<T>([]);


  /// The current errors related to the value in this control, as determined by the [validators]
  Map<String, dynamic> get errors => _errors;

  /// Whether this control is enabled. When enabled, users should be able to interact with the view
  /// and make changes to the value of this control. When disabled, users should not be able to
  /// interact with the view bound to this control. This behaviour must be enforced within the view.
  bool get enabled => _enabled;

  /// Whether input fields bound to this control should display error messages. There is no
  /// relationship between this field and [enabled]. It is up to the implementation of input fields
  /// to decide whether [enabled] status should also impact whether error messages are displayed.
  bool get displayErrors => _displayErrors;

  /// Check whether this control is valid, that is - it has no errors.
  bool get isValid => _errors.length == 0;

  /// The current set of validators used to validate the value in this contorl.
  ValidatorSet<T> get validators => _validators;

  /// Get the value of the control. If this control is disabled, the value will be returned as null
  T get value => _value;
  Stream<T> get valueUpdated => _valueController.stream;


  /// Should only be used by the view input field which is binding to this control. The
  /// [ViewNotifier] allows the view to receive updates including value, errors or state changes
  /// occur in this control. To respond to user input, listen to the [valueUpdated] stream instead.
  registerModelUpdatedListener(ViewNotifier notifier) {
    _viewNotifier = notifier;
  }

  /// Should only be used by view input fields when the user updates the value within the view.
  /// Results in [valueUpdated] emitting a new event. To programmatically change the value in
  /// the view, use the [setValue] method instead.
  onViewValueUpdated(T newValue) {
    _value = newValue;
    _updateErrors();
    _notifyView({
      ModelUpdateType.Errors: errors
    });
    _valueController.add(_value);
  }

  /// Update the view with a new value. Results in the [ViewNotifier] informing the view that it
  /// needs to rebuild with the new value.
  setValue(T newValue) {
    _value = newValue;
    _updateErrors();
    _notifyView({
      ModelUpdateType.Value: _value,
      ModelUpdateType.Errors: _errors
    });
    _valueController.add(newValue);
  }

  /// Update the validators that should be run when this control is validated.
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
    _updateErrors();
    _notifyView({ModelUpdateType.Errors: errors});
  }

  /// Whether this input field bound to this control is displaying its errors. Typically enabled
  /// either on blur of input fields, or on a form submit button press.
  setDisplayErrors(bool displayErrors) {
    _displayErrors = displayErrors;
    _notifyView({ModelUpdateType.State: true});
  }


  /// Whether this control should be enabled: i.e. whether the view input field bound to this
  /// control should accept user input. It is up to the view to decide how disabled state should
  /// be presented. Typical options include greying out the field, or hiding it altogether.
  setEnabled(bool enabled) {
    _enabled = enabled;
    _notifyView({ModelUpdateType.State: true});
  }


  /// Notify the a bound input view field of changes
  _notifyView(Map<ModelUpdateType, dynamic> updates) {
    if (_viewNotifier != null) {
      _viewNotifier(updates);
    }
  }

  /// Run the validators and calculate errors for this control
  void _updateErrors() {
    final errors = _validators(this);
    _errors.clear();
    _errors.addAll(errors);
  }


}



class FormControl<T> extends AbstractControl<T> {
  FormControl({T initialValue, ValidatorSet<T> validators, bool displayErrors = false, }) {
    if (initialValue != null) {
      _value = initialValue;
    }
    if (validators != null) {
      _validators = validators;
    }
    _displayErrors = displayErrors == true;
    _updateErrors();
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
      final validatorErrors = validator.validate(control);
      if (validatorErrors != null) {
        errors.addAll(validatorErrors);
      }
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

//class FormGroup<T> extends AbstractControl<T> {
//
//  final Deserializer<T> deserializer;
//  final Map<String, FormControl> controls;
//
//  FormGroup({@required this.deserializer, @required this.controls, bool autoValidate = false}) {
//    this._autoValidate = autoValidate == true;
//  }
//
//  FormControl getControl(String controlName) {
//    return controls[controlName];
//  }
//}
//
//class FormArray<T> extends AbstractControl<List<T>> {
//
//}
//
//class FormBuilder {
//
//
//  FormGroup group<GroupType>({GroupType initialValue, List<FormGroupControl<GroupType, dynamic>> controls}) {
//    return FormGroup<GroupType>(initialValue, controls);
//  }
//}