class Validadores {

  static String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail é obrigatório';
    }

    final regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!regex.hasMatch(valor)) {
      return 'Digite um e-mail válido (ex: aluno@unigo.com)';
    }
    return null;
  }

  static String? validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  static String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O nome é obrigatório';
    }
    return null;
  }
}
