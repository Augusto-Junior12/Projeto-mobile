class Validadores {
  // Validação de E-mail
  static String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O e-mail é obrigatório';
    }
    // Expressão regular (Regex) para verificar se o e-mail tem o formato correto
    final regex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!regex.hasMatch(valor)) {
      return 'Digite um e-mail válido (ex: aluno@unigo.com)';
    }
    return null; // Retornar nulo significa que a validação passou
  }

  // Validação de Senha
  static String? validarSenha(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'A senha é obrigatória';
    }
    if (valor.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  // Validação de Nome (para a tela de cadastro)
  static String? validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'O nome é obrigatório';
    }
    return null;
  }
}