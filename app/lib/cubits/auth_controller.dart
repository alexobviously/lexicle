import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:word_game/services/api_client.dart';
import 'package:word_game/services/service_locator.dart';

class AuthController extends Cubit<AuthState> with ReadyManager {
  AuthController() : super(AuthState.initial()) {
    init();
  }

  @override
  void initialise() async {
    final token = await storage().read(key: 'token');
    final expiry = int.parse(await storage().read(key: 'expiry') ?? '0');
    if (token != null && expiry > nowMs()) {
      emit(state.copyWith(token: token, expiry: expiry, working: true));
      final _result = await ApiClient.getMe();
      if (_result.ok) {
        emit(state.copyWith(user: _result.object!, working: false));
        refreshUserStats();
      } else {
        emit(AuthState.initial());
        storage().delete(key: 'token');
        storage().delete(key: 'expiry');
      }
    }
    setReady();
  }

  Future<Result<User>> login(String username, String password) async {
    emit(state.copyWith(working: true));
    final _result = await ApiClient.login(username, password);
    if (_result.ok) {
      onLogin(_result.object!, _result.token!, _result.expiry!);
      return Result.ok(_result.object!);
    } else {
      return Result.error(_result.error!);
    }
  }

  Future<Result<User>> register(String username, String password) async {
    emit(state.copyWith(working: true));
    final _result = await ApiClient.register(username, password);
    if (_result.ok) {
      onLogin(_result.object!, _result.token!, _result.expiry!);
      return Result.ok(_result.object!);
    } else {
      return Result.error(_result.error!);
    }
  }

  void onLogin(User user, String token, int expiry) {
    userStore().set(user);
    emit(state.copyWith(
      user: user,
      token: token,
      expiry: expiry,
      working: false,
    ));
    refreshUserStats();
    challengeManager().refresh(clear: true);
  }

  void logout() {
    emit(AuthState.initial());
    challengeManager().refresh(clear: true);
  }

  void updateToken(String token, int expiry) {
    if (token != state.token || expiry != state.expiry) {
      emit(state.copyWith(token: token, expiry: expiry));
      storage().write(key: 'token', value: token);
      storage().write(key: 'expiry', value: expiry.toString());
    }
  }

  void refresh() {
    refreshUser();
    refreshUserStats();
  }

  void refreshUser() async {
    if (userId == null) return;
    final result = await userStore().getRemote(userId!);
    if (result.ok) {
      emit(state.copyWith(user: result.object!));
    }
  }

  void refreshUserStats() async {
    if (userId == null) return;
    final result = await ustatsStore().getMe();
    if (result.ok) {
      emit(state.copyWith(stats: result.object!));
    }
  }

  Future<Result<bool>> joinTeam(String id) async {
    if (userId == null) return Result.error(Errors.unauthorised);
    final result = await ApiClient.joinTeam(id);
    if (result.ok) {
      emit(state.copyWith(user: result.object!));
      userStore().set(result.object!);
      return Result.ok(true);
    } else {
      return Result.error(result.error!);
    }
  }

  Future<Result<bool>> leaveTeam() async {
    if (userId == null) return Result.error(Errors.unauthorised);
    final result = await ApiClient.leaveTeam();
    if (result.ok) {
      emit(state.copyWith(user: result.object!));
      userStore().set(result.object!);
      return Result.ok(true);
    } else {
      return Result.error(result.error!);
    }
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
  final UserStats? stats;
  final String? token;
  final int? expiry;

  bool get hasToken => token != null;
  bool get loggedIn => user != null;
  String? get userId => user?.id;
  String? get username => user?.username;

  AuthState({
    this.working = false,
    this.user,
    this.stats,
    this.token,
    this.expiry,
  });
  factory AuthState.initial() => AuthState();

  AuthState copyWith({
    bool? working,
    User? user,
    UserStats? stats,
    String? token,
    int? expiry,
  }) =>
      AuthState(
        working: working ?? this.working,
        user: user ?? this.user,
        stats: stats ?? this.stats,
        token: token ?? this.token,
        expiry: expiry ?? this.expiry,
      );
}
