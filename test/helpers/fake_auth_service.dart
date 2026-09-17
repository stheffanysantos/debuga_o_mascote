import 'package:debuga_o_mascote/core/auth/auth_service.dart';

/// [AuthService] de teste — nunca toca o Firebase Auth de verdade, e deixa
/// o teste controlar o resultado de cada chamada (mesmo espírito de
/// `FakeSoundPlayer`/`FakeLeaderboardRepository`).
class FakeAuthService implements AuthService {
  FakeAuthService({bool hasAccount = false, String? displayName}) : _hasAccount = hasAccount, _displayName = displayName;

  bool _hasAccount;
  String? _displayName;

  /// Se não-nulo, toda chamada devolve essa mensagem de erro em vez de
  /// suceder — simula falha de rede/credencial errada.
  String? errorToReturn;

  @override
  bool get hasAccount => _hasAccount;

  @override
  String? get displayName => _displayName;

  @override
  Future<String?> registerWithEmail({required String name, required String email, required String password}) async {
    if (errorToReturn != null) return errorToReturn;
    _hasAccount = true;
    _displayName = name;
    return null;
  }

  @override
  Future<String?> signInWithEmail({required String email, required String password}) async {
    if (errorToReturn != null) return errorToReturn;
    _hasAccount = true;
    _displayName = email;
    return null;
  }

  @override
  Future<String?> signInWithGoogle() async {
    if (errorToReturn != null) return errorToReturn;
    _hasAccount = true;
    _displayName = 'Conta Google';
    return null;
  }

  @override
  Future<void> signOut() async {
    _hasAccount = false;
    _displayName = null;
  }
}
