class UsuarioModel {
  final String? uid;
  final String nome;
  final String curso;
  final String matricula;
  final String email;
  final String? senha;
  final String? fotoPath;
  final List<String> rotasSeguidas;

  const UsuarioModel({
    this.uid,
    required this.nome,
    required this.curso,
    required this.matricula,
    required this.email,
    this.senha,
    this.fotoPath,
    this.rotasSeguidas = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'curso': curso,
      'matricula': matricula,
      'email': email,
      'fotoPath': fotoPath,
      'rotasSeguidas': rotasSeguidas,
    };
  }

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      uid: map['uid'] as String?,
      nome: map['nome'] as String,
      curso: map['curso'] as String,
      matricula: map['matricula'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String?,
      fotoPath: map['fotoPath'] as String?,
      rotasSeguidas: List<String>.from(map['rotasSeguidas'] ?? []),
    );
  }

  UsuarioModel copyWith({
    String? uid,
    String? nome,
    String? curso,
    String? matricula,
    String? email,
    String? senha,
    String? fotoPath,
    List<String>? rotasSeguidas,
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      fotoPath: fotoPath ?? this.fotoPath,
      rotasSeguidas: rotasSeguidas ?? this.rotasSeguidas,
    );
  }

  /// Criadores têm email @unigo.com; demais são leitores.
  bool get isCriador => email.toLowerCase().endsWith('@unigo.com');

  @override
  String toString() {
    return 'UsuarioModel(uid: $uid, nome: $nome, curso: $curso, matricula: $matricula, email: $email, fotoPath: $fotoPath, isCriador: $isCriador)';
  }
}
