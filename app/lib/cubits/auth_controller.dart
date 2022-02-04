import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:fluttering_phrases/fluttering_phrases.dart' as fp;

// this logic is temporary, we will be using Auth0 later
class AuthController extends Cubit<AuthState> {
  AuthController() : super(AuthState.initial());

  void setName(String name) => emit(AuthState(name: name));
}

class AuthState {
  final String name;
  final User? user;
  final String? token;

  AuthState({
    required this.name,
    this.user,
    this.token,
  });
  factory AuthState.initial() => AuthState(name: fp.generate());

  AuthState copyWith({
    String? name,
    User? user,
    String? token,
  }) =>
      AuthState(
        name: name ?? this.name,
        user: user ?? this.user,
        token: token ?? this.token,
      );
}
