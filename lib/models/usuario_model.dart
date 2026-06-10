// Modelo de dados do usuário — representa uma linha da tabela 'usuarios' no SQLite
class UsuarioModel {
  final int? id;
  final String nome;
  final String curso;
  final String matricula;
  final String email;
  final String senha;
  final String? fotoPath;

  const UsuarioModel({
    this.id,
    required this.nome,
    required this.curso,
    required this.matricula,
    required this.email,
    required this.senha,
    this.fotoPath,
  });

  // Converte o objeto para Map (usado no insert/update do sqflite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'curso': curso,
      'matricula': matricula,
      'email': email,
      'senha': senha,
      'fotoPath': fotoPath,
    };
  }

  // Cria um UsuarioModel a partir de um Map retornado pelo sqflite
  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      curso: map['curso'] as String,
      matricula: map['matricula'] as String,
      email: map['email'] as String,
      senha: map['senha'] as String,
      fotoPath: map['fotoPath'] as String?,
    );
  }

  // Retorna uma cópia do objeto com campos alterados (útil para edição)
  UsuarioModel copyWith({
    int? id,
    String? nome,
    String? curso,
    String? matricula,
    String? email,
    String? senha,
    String? fotoPath,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
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
    return 'UsuarioModel(id: $id, nome: $nome, curso: $curso, matricula: $matricula, email: $email, fotoPath: $fotoPath)';
  }
}
