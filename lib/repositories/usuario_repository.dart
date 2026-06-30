import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projeto_app/models/usuario_model.dart';

class UsuarioRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> atualizar(UsuarioModel usuario) async {
    await _firestore
        .collection('usuarios')
        .doc(usuario.uid)
        .update(usuario.toMap());
  }

  Future<void> deletar(String uid) async {
    await _firestore.collection('usuarios').doc(uid).delete();
    await _auth.currentUser?.delete();
  }

  Future<bool> emailDisponivel(String email) async {
    return true;
  }

  Future<void> atualizarRotasSeguidas(String uid, List<String> rotasIds) async {
    try {
      await _firestore.collection('usuarios').doc(uid).update({
        'rotasSeguidas': rotasIds,
      });
    } catch (e) {
      debugPrint('[UsuarioRepository] Erro ao atualizar rotas seguidas: $e');
    }
  }
}
