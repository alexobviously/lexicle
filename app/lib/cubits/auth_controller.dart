import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:fluttering_phrases/fluttering_phrases.dart' as fp;
import 'package:word_game/services/service_locator.dart';

class AuthController extends Cubit<AuthState> {
  AuthController() : super(AuthState.initial());

  void onLogin(User user, String token, int expiry) {
    userStore().set(user);
    emit(state.copyWith(user: user, token: token, expiry: expiry));
  }

  void logout() {
    emit(AuthState.initial());
  }

  String? get token => state.token;
  bool get hasToken => state.hasToken;
  bool get loggedIn => state.loggedIn;
  String? get userId => state.user?.id;
  String? get username => state.user?.username;
}

class AuthState {
  final User? user;
  final String? token;
  final int? expiry;

  bool get hasToken => token != null;
  bool get loggedIn => user != null;

  AuthState({
    this.user,
    this.token,
    this.expiry,
  });
  factory AuthState.initial() => AuthState();

  AuthState copyWith({
    User? user,
    String? token,
    int? expiry,
  }) =>
      AuthState(
        user: user ?? this.user,
        token: token ?? this.token,
        expiry: expiry ?? this.expiry,
      );
}
