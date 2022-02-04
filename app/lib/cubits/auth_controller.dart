import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:fluttering_phrases/fluttering_phrases.dart' as fp;
import 'package:word_game/services/service_locator.dart';

class AuthController extends Cubit<AuthState> {
  AuthController() : super(AuthState.initial());

  void setName(String name) => emit(AuthState(name: name));

  void onLogin(User user, String token, int expiry) {
    userStore().set(user);
    emit(state.copyWith(user: user, token: token, expiry: expiry));
  }

  String? get token => state.token;
  bool get hasToken => state.hasToken;
}

class AuthState {
  final String name;
  final User? user;
  final String? token;
  final int? expiry;

  bool get hasToken => token != null;
  bool get loggedIn => user != null;

  AuthState({
    required this.name,
    this.user,
    this.token,
    this.expiry,
  });
  factory AuthState.initial() => AuthState(name: fp.generate());

  AuthState copyWith({
    String? name,
    User? user,
    String? token,
    int? expiry,
  }) =>
      AuthState(
        name: name ?? this.name,
        user: user ?? this.user,
        token: token ?? this.token,
        expiry: expiry ?? this.expiry,
      );
}
