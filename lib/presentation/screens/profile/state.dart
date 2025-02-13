import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial state before any data is loaded
class ProfileInitial extends ProfileState {}

// State when profile data is loading
class ProfileLoading extends ProfileState {}

// State when profile data is successfully loaded
class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String age;
  final String gender;
  final String phone;
  // final String profilePic;

  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.phone,
    // required this.profilePic,
  });

  @override
  List<Object?> get props => [name, email, age, gender, phone];
}

// State when there is an error fetching the profile
class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
