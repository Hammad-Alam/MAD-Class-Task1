import '../enums/auth_status.dart';
import '../enums/gender.dart';
import '../models/user_model.dart';

class AuthController {
  static final AuthController _instance = AuthController._internal();
  factory AuthController() => _instance;
  AuthController._internal();

  final List<UserModel> _registeredUsers = [];
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _rememberMe = false;
  String? _rememberedEmail;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  bool get rememberMe => _rememberMe;
  String? get rememberedEmail => _rememberedEmail;

  void setRememberMe(bool value) {
    _rememberMe = value;
  }

  bool register({
    required String fullName,
    required String email,
    required String password,
    required Gender gender,
  }) {
    final existingUser = _registeredUsers.any(
      (user) => user.email.toLowerCase() == email.toLowerCase(),
    );

    if (existingUser) {
      return false;
    }

    final newUser = UserModel(
      fullName: fullName,
      email: email,
      password: password,
      gender: gender,
    );

    _registeredUsers.add(newUser);
    return true;
  }

  bool login({required String email, required String password}) {
    _status = AuthStatus.loading;

    try {
      final user = _registeredUsers.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password,
        orElse: () => throw Exception('Invalid credentials'),
      );

      _currentUser = user;
      _status = AuthStatus.authenticated;

      if (_rememberMe) {
        _rememberedEmail = email;
      } else {
        _rememberedEmail = null;
      }

      return true;
    } catch (e) {
      _status = AuthStatus.error;
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    if (!_rememberMe) {
      _rememberedEmail = null;
    }
  }

  bool hasRegisteredUsers() {
    return _registeredUsers.isNotEmpty;
  }
}
