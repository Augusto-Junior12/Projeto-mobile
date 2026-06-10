import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// DatabaseHelper — Singleton responsável por abrir e criar o banco SQLite
class DatabaseHelper {
  // Instância única (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter: retorna o banco (abre se ainda não estiver aberto)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('unigo.db');
    return _database!;
  }

  // Inicializa o arquivo do banco de dados no diretório padrão do dispositivo
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Criação das tabelas na primeira execução
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id        INTEGER PRIMARY KEY AUTOINCREMENT,
        nome      TEXT    NOT NULL,
        curso     TEXT    NOT NULL,
        matricula TEXT    NOT NULL UNIQUE,
        email     TEXT    NOT NULL UNIQUE,
        senha     TEXT    NOT NULL,
        fotoPath  TEXT
      )
    ''');

    // Cria o usuário administrador padrão
    await db.insert('usuarios', {
      'nome': 'Administrador',
      'curso': 'TI / Administração',
      'matricula': '000000',
      'email': 'Admin@unigo.com',
      'senha': '111111',
      'fotoPath': null,
    });
  }

  // Migração e atualizações do banco de dados
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE usuarios ADD COLUMN fotoPath TEXT');
      } catch (_) {
        // Ignora caso a coluna já exista por algum motivo
      }

      // Verifica se o administrador padrão já existe, senão insere
      final adminExistente = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: ['Admin@unigo.com'],
        limit: 1,
      );

      if (adminExistente.isEmpty) {
        await db.insert('usuarios', {
          'nome': 'Administrador',
          'curso': 'TI / Administração',
          'matricula': '000000',
          'email': 'Admin@unigo.com',
          'senha': '111111',
          'fotoPath': null,
        });
      }
    }
  }

  // Fecha a conexão com o banco (usado ao encerrar o app)
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}
