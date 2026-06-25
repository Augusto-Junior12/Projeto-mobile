import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyEmail = 'bio_email';
  static const _keySenha = 'bio_senha';
  static const _keyAtivada = 'bio_ativada';

  Future<bool> disponivel() async {
    try {
      final capaz = await _auth.canCheckBiometrics;
      final suportado = await _auth.isDeviceSupported();
      if (!capaz || !suportado) return false;

      final tipos = await _auth.getAvailableBiometrics();
      return tipos.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Erro ao verificar disponibilidade: $e');
      return false;
    }
  }

  Future<bool> estaAtivada() async {
    final valor = await _storage.read(key: _keyAtivada);
    return valor == 'true';
  }

  Future<bool> autenticar() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Use sua digital ou rosto para entrar no UniGo',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('[BiometricService] Erro na autenticação biométrica: $e');
      return false;
    }
  }

  Future<void> salvarCredenciais(String email, String senha) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keySenha, value: senha);
    await _storage.write(key: _keyAtivada, value: 'true');
    debugPrint('[BiometricService] Credenciais salvas com sucesso.');
  }

  Future<({String email, String senha})?> lerCredenciais() async {
    final email = await _storage.read(key: _keyEmail);
    final senha = await _storage.read(key: _keySenha);
    if (email == null || senha == null) return null;
    return (email: email, senha: senha);
  }

  Future<String?> getEmailVinculado() async {
    return await _storage.read(key: _keyEmail);
  }

  Future<void> desativar() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keySenha);
    await _storage.write(key: _keyAtivada, value: 'false');
    debugPrint('[BiometricService] Biometria desativada.');
  }
}