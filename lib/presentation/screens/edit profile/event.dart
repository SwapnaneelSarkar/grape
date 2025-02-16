import 'package:equatable/equatable.dart';

class EditProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateProfileSubmitted extends EditProfileEvent {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String username;

  UpdateProfileSubmitted({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    required this.username,
  });

  @override
  List<Object?> get props => [name, email, phone, dob, username];
}
