import 'package:projeto_app/database/database_helper.dart';
import 'package:projeto_app/models/usuario_model.dart';

// UsuarioRepository — camada de repositório responsável por todas as
// operações CRUD da tabela 'usuarios'. As telas NÃO acessam o banco diretamente.
class UsuarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ── INSERT ──────────────────────────────────────────────────────────────────
  // Cadastra um novo usuário. Retorna o ID gerado ou lança exceção se o
  // e-mail/matrícula já existirem (constraint UNIQUE do banco).
  Future<int> cadastrar(UsuarioModel usuario) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'usuarios',
      usuario.toMap()..remove('id'), // não passa o id (autoincrement)
    );
  }

  // ── SELECT: login ────────────────────────────────────────────────────────────
  // Retorna o usuário que corresponde ao e-mail + senha informados,
  // ou null se não encontrar (credenciais inválidas).
  Future<UsuarioModel?> login(String email, String senha) async {
    final db = await _dbHelper.database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return UsuarioModel.fromMap(resultado.first);
  }

  // ── SELECT: buscar por ID ────────────────────────────────────────────────────
  Future<UsuarioModel?> buscarPorId(int id) async {
    final db = await _dbHelper.database;
    final resultado = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return UsuarioModel.fromMap(resultado.first);
  }

  // ── SELECT: buscar por e-mail ────────────────────────────────────────────────
  Future<UsuarioModel?> buscarPorEmail(String email) async {
    final db = await _dbHelper.database;
    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (resultado.isEmpty) return null;
    return UsuarioModel.fromMap(resultado.first);
  }

  // ── SELECT ALL ───────────────────────────────────────────────────────────────
  Future<List<UsuarioModel>> listarTodos() async {
    final db = await _dbHelper.database;
    final resultado = await db.query('usuarios');
    return resultado.map(UsuarioModel.fromMap).toList();
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────────
  // Atualiza nome, curso e matrícula do usuário com o id fornecido.
  // Retorna o número de linhas afetadas (0 = nenhuma linha encontrada).
  Future<int> atualizar(UsuarioModel usuario) async {
    final db = await _dbHelper.database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // ── DELETE ───────────────────────────────────────────────────────────────────
  Future<int> deletar(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── VERIFICAR e-mail único ───────────────────────────────────────────────────
  // Retorna true se o e-mail ainda não está cadastrado
  Future<bool> emailDisponivel(String email) async {
    final usuario = await buscarPorEmail(email);
    return usuario == null;
  }
}
