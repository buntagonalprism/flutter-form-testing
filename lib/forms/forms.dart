
import 'dart:async';

import 'package:equatable/equatable.dart';

enum ModelUpdate {
  Value,
  Errors,
  State
}

typedef ViewNotifier(List<ModelUpdate> updates);

abstract class AbstractControl<T> {

  T _value;
  final _errors = Map<String, dynamic>();


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

  /// The current set of validators used to validate the value in this control.
  ValidatorSet<T> get validators => _validators;

  /// Get the value of the control. If this control is disabled, the value will be returned as null
  T get value => _value;

  /// Update the value of this control
  setValue(T value);

  /// Update the validators that should be run when this control is validated.
  setValidators(ValidatorSet<T> validators);

  /// Whether this input field bound to this control is displaying its errors. Typically enabled
  /// either on blur of input fields, or on a form submit button press.
  setDisplayErrors(bool displayErrors);

  /// Whether this control should be enabled: i.e. whether the view input field bound to this
  /// control should accept user input. It is up to the view to decide how disabled state should
  /// be presented. Typical options include greying out the field, or hiding it altogether.
  setEnabled(bool enabled);


  /// Run the validators and calculate errors for this control
  void _updateErrors() {
    final errors = _validators(this);
    _errors.clear();
    _errors.addAll(errors);
  }

}



class FormControl<T> extends AbstractControl<T> {
  final _valueController = StreamController<T>.broadcast();
  Stream<T> get valueUpdated => _valueController.stream;

  FormControl({T initialValue, ValidatorSet<T> validators, bool displayErrors = false, bool enabled = true}) {
    if (initialValue != null) {
      _value = initialValue;
    }
    if (validators != null) {
      _validators = validators;
    }
    _displayErrors = displayErrors == true;
    _enabled = enabled == true;
    _updateErrors();
  }

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
    _notifyView([ModelUpdate.Errors]);
    _notifyValueListeners();
  }

  @override
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
    _updateErrors();
    _notifyView([ModelUpdate.Errors]);
  }

  @override
  setDisplayErrors(bool displayErrors) {
    _displayErrors = displayErrors;
    _notifyView([ModelUpdate.State]);
  }

  @override
  setEnabled(bool enabled) {
    _enabled = enabled;
    _notifyView([ModelUpdate.State]);
  }

  /// Update the view with a new value. Results in the [ViewNotifier] informing the view that it
  /// needs to rebuild with the new value.
  @override
  setValue(T newValue) {
    _value = newValue;
    _updateErrors();
    _notifyView([ModelUpdate.Value, ModelUpdate.Errors]);
    _notifyValueListeners();
  }

  /// Notify the a bound input view field of changes
  _notifyView(List<ModelUpdate> updates) {
    if (_viewNotifier != null) {
      _viewNotifier(updates);
    }
  }

  void _notifyValueListeners() {
    _valueController.add(_value);
  }
}

typedef Deserializer<T> = T Function(Map<String, dynamic> source);

class FormGroup<T> extends AbstractControl<T> {
  final Map<String, AbstractControl> controls;
  final Deserializer<T> deserializer;
  FormGroup(this.controls, this.deserializer, {
    T initialValue,
    bool displayErrors,
    bool enabled,
    ValidatorSet<T> validators,
  }) {
    if (initialValue != null) {
      setValue(initialValue);
    }
    if (displayErrors != null) {
      setDisplayErrors(displayErrors);
    }
    if (enabled != null) {
      setEnabled(enabled);
    }
    _validators = validators ?? ValidatorSet<T>([]);
  }

  FormControl getControl(String key) {
    return controls[key];
  }

  @override
  T get value {
    final values = Map<String, dynamic>();
    controls.forEach((key, control) {
      if (control.enabled) {
        values[key] = control.value;
      } else {
        values[key] = null;
      }
    });
    return deserializer(values);
  }

  @override
  setDisplayErrors(bool displayErrors) {
    _displayErrors = displayErrors;
    controls.forEach((_, control) {
      control.setDisplayErrors(displayErrors);
    });
  }

  @override
  setEnabled(bool enabled) {
    _enabled = enabled;
    controls.forEach((_, control) {
      control.setEnabled(enabled);
    });
  }

  @override
  setValue(T value) {
    final initialValues = _serialize(value);
    initialValues.forEach((key, value) {
      if (controls.containsKey(key)) {
        controls[key].setValue(initialValues[key]);
      }
    });
  }

  @override
  setValidators(ValidatorSet<T> validators) {
    _validators = validators;
  }

  Map<String, dynamic> _serialize(value) {
    try {
      Map<String, dynamic> values = value.toJson();
      return values;
    } on NoSuchMethodError catch(_) {
      throw "Class ${value.runtimeType} must have a toJson() method returning Map<String, dynamic> to be used with FormGroup";
    }
  }

  @override
  Map<String, dynamic> get errors {
    final allControlErrors = Map<String, dynamic>();
    controls.forEach((key, control) {
      final controlErrors = control.errors;
      if (controlErrors.length > 0) {
        allControlErrors[key] = controlErrors;
      }
    });
    final groupErrors = _validators(this);
    if (allControlErrors.length > 0) {
      groupErrors['controlErrors'] = allControlErrors;
    }
    return groupErrors;
  }



  @override
  bool get isValid => errors.length == 0;
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
