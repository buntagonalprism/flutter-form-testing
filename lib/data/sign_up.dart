import 'package:json_annotation/json_annotation.dart';

part 'sign_up.g.dart';

@JsonSerializable()
class SignUp {

  SignUp();

  String email;
  String password;
  String confirmation;

  Map<String, dynamic> toJson() => _$SignUpToJson(this);
  static SignUp fromJson(Map<String, dynamic> json) => _$SignUpFromJson(json);

}