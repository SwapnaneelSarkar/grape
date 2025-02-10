import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object?> get props => [];
}

class EmailChanged extends SignupEvent {
  final String email;

  const EmailChanged(this.email);

  @override
  List<Object?> get props => [email];
}

class UsernameChanged extends SignupEvent {
  final String username;

  const UsernameChanged(this.username);

  @override
  List<Object?> get props => [username];
}

class PasswordChanged extends SignupEvent {
  final String password;

  const PasswordChanged(this.password);

  @override
  List<Object?> get props => [password];
}

class NameChanged extends SignupEvent {
  final String name;

  const NameChanged(this.name);

  @override
  List<Object?> get props => [name];
}

class DobChanged extends SignupEvent {
  final String dob;

  const DobChanged(this.dob);

  @override
  List<Object?> get props => [dob];
}

class PhoneChanged extends SignupEvent {
  final String phone;

  const PhoneChanged(this.phone);

  @override
  List<Object?> get props => [phone];
}

class SignupSubmitted extends SignupEvent {
  final String name;
  final String email;
  final String password;
  final String dob;
  final String phone;
  final String username;

  const SignupSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.dob,
    required this.phone,
    required this.username,
  });

  @override
  List<Object?> get props => [name, email, password, dob, phone, username];
}
