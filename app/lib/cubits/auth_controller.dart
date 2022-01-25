import 'package:bloc/bloc.dart';
import 'package:fluttering_phrases/fluttering_phrases.dart' as fp;

// this logic is temporary, we will be using Auth0 later
class AuthController extends Cubit<AuthState> {
  AuthController() : super(AuthState.initial());

  void setName(String name) => emit(AuthState(name: name));
}

class AuthState {
  final String name;
  AuthState({required this.name});
  factory AuthState.initial() => AuthState(name: fp.generate());
}
