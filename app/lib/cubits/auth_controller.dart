import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/service_locator.dart';

class AuthController extends Cubit<AuthState> {
  AuthController() : super(AuthState.initial());

  void init() {}

  Future<Result<User>> login(String username, String password) async {
    final _result = await ApiClient.login(username, password);
    if (_result.ok) {
      onLogin(_result.object!, _result.token!, _result.expiry!);
      return Result.ok(_result.object!);
    } else {
      return Result.error(_result.error!);
    }
  }

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
  String? get userId => state.userId;
  String? get username => state.username;
}

class AuthState {
  final bool working;
  final User? user;
  final String? token;
  final int? expiry;

  bool get hasToken => token != null;
  bool get loggedIn => user != null;
  String? get userId => user?.id;
  String? get username => user?.username;

  AuthState({
    this.working = false,
    this.user,
    this.token,
    this.expiry,
  });
  factory AuthState.initial() => AuthState();

  AuthState copyWith({
    bool? working,
    User? user,
    String? token,
    int? expiry,
  }) =>
      AuthState(
        working: working ?? this.working,
        user: user ?? this.user,
        token: token ?? this.token,
        expiry: expiry ?? this.expiry,
      );
}
