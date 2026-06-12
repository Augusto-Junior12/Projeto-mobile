// Modelo de dados do usuário — representa um documento da coleção 'usuarios' no Firestore
class UsuarioModel {
  final String? uid;
  final String nome;
  final String curso;
  final String matricula;
  final String email;
  final String? senha;     // apenas em memória durante o cadastro; NUNCA gravada no Firestore
  final String? fotoPath;

  const UsuarioModel({
    this.uid,
    required this.nome,
    required this.curso,
    required this.matricula,
    required this.email,
    this.senha,            // opcional — não é exigida fora do fluxo de cadastro/login
    this.fotoPath,
  });

  // Converte o objeto para Map destinado ao Firestore.
  // O campo [senha] é intencionalmente omitido — autenticação é
  // responsabilidade exclusiva do Firebase Auth, não do Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'curso': curso,
      'matricula': matricula,
      'email': email,
      'fotoPath': fotoPath,
      // senha NÃO é gravada no Firestore
    };
  }

  // Reconstrói o modelo a partir de um documento do Firestore.
  // [senha] não existe no Firestore, portanto fica null por padrão.
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      uid: map['uid'] as String?,
      nome: map['nome'] as String,
      curso: map['curso'] as String,
      matricula: map['matricula'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String?,   // campo ausente no Firestore → null
      fotoPath: map['fotoPath'] as String?,
    );
  }

  // Retorna uma cópia do objeto com campos alterados (útil para edição)
  UsuarioModel copyWith({
    String? uid,
    String? nome,
    String? curso,
    String? matricula,
    String? email,
    String? senha,
    String? fotoPath,
  }) {
    return UsuarioModel(
      uid: uid ?? this.uid,
      nome: nome ?? this.nome,
      curso: curso ?? this.curso,
      matricula: matricula ?? this.matricula,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }

  @override
  String toString() {
    return 'UsuarioModel(uid: $uid, nome: $nome, curso: $curso, matricula: $matricula, email: $email, fotoPath: $fotoPath)';
  }
}