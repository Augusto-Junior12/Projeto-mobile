import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_app/models/usuario_model.dart';

// UsuarioRepository — camada de repositório responsável por todas as
// operações CRUD de usuários. As telas NÃO acessam o Firebase diretamente.
class UsuarioRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── INSERT ──────────────────────────────────────────────────────────────────
  // Cadastra um novo usuário no Firebase Auth e salva o perfil no Firestore.
  Future<void> cadastrar(UsuarioModel usuario, String senha) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: usuario.email,
      password: senha,
    );
    final uid = credencial.user!.uid;
    await _firestore.collection('usuarios').doc(uid).set({
      'uid': uid,
      'nome': usuario.nome,
      'curso': usuario.curso,
      'matricula': usuario.matricula,
      'email': usuario.email,
      'fotoPath': usuario.fotoPath,
    });
  }

  // ── SELECT: login ────────────────────────────────────────────────────────────
  // Autentica via Firebase Auth e busca o perfil no Firestore.
  // Retorna null se as credenciais forem inválidas.
  Future<UsuarioModel?> login(String email, String senha) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: email,
      password: senha,
    );
    final uid = credencial.user!.uid;
    final doc = await _firestore.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;
    return UsuarioModel.fromMap(doc.data()!);
  }

  // ── UPDATE ───────────────────────────────────────────────────────────────────
  // Atualiza os dados do perfil do usuário no Firestore.
  Future<void> atualizar(UsuarioModel usuario) async {
    await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .update(usuario.toMap());
  }

  // ── DELETE ───────────────────────────────────────────────────────────────────
  // Remove o documento do Firestore e a conta do Firebase Auth.
  Future<void> deletar(String uid) async {
    await _firestore.collection('usuarios').doc(uid).delete();
    await _auth.currentUser?.delete();
  }

  // ── VERIFICAR e-mail único ───────────────────────────────────────────────────
  // fetchSignInMethodsForEmail foi depreciado pelo Firebase por razões de segurança.
  // A verificação agora é feita pelo próprio Auth ao cadastrar —
  // ele lança FirebaseAuthException com code 'email-already-in-use'.
  Future<bool> emailDisponivel(String email) async {
    return true;
  }
}