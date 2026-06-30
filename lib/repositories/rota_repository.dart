import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projeto_app/services/map_route_service.dart';

/// Repositório para operações CRUD de rotas na coleção global `rotas`.
class RotaRepository {
  static final RotaRepository _instance = RotaRepository._internal();
  factory RotaRepository() => _instance;
  RotaRepository._internal();

  final _col = FirebaseFirestore.instance.collection('rotas');

  /// Carrega todas as rotas da coleção global.
  Future<List<RouteInfo>> carregarTodas() async {
    try {
      final snapshot = await _col.get();
      return snapshot.docs.map((doc) {
        return RouteInfo.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint('[RotaRepository] Erro ao carregar rotas: $e');
      return [];
    }
  }

  /// Salva (cria ou atualiza) uma rota.
  Future<void> salvar(RouteInfo rota) async {
    try {
      await _col.doc(rota.id).set(rota.toMap());
    } catch (e) {
      debugPrint('[RotaRepository] Erro ao salvar rota: $e');
    }
  }

  /// Edita uma rota existente (merge).
  Future<void> editar(RouteInfo rota) async {
    try {
      await _col.doc(rota.id).update(rota.toMap());
    } catch (e) {
      debugPrint('[RotaRepository] Erro ao editar rota: $e');
    }
  }

  /// Deleta uma rota pelo ID.
  Future<void> deletar(String rotaId) async {
    try {
      await _col.doc(rotaId).delete();
    } catch (e) {
      debugPrint('[RotaRepository] Erro ao deletar rota: $e');
    }
  }

  Future<void> migrarRotasPadrao() async {
    try {
      final snapshot = await _col.limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('[RotaRepository] Rotas já existem no Firestore. Migração pulada.');
        return;
      }

      const createdBy = 'admin@unigo.com';

      final rotasPadrao = [
        RouteInfo(
          id: 'rota_padrao_1',
          name: 'Rota 1 - Ônibus A',
          origin: 'Centro, Lagarto - SE',
          destination: 'IFS Campus Lagarto',
          estimatedTime: '30 minutos',
          geoJsonIndex: 0,
          createdBy: createdBy,
        ),
        RouteInfo(
          id: 'rota_padrao_2',
          name: 'Rota 2 - Ônibus B',
          origin: 'Rodoviária - Tv. Josias Machado, 178',
          destination: 'IFS Campus Lagarto',
          estimatedTime: '25 minutos',
          geoJsonIndex: 1,
          createdBy: createdBy,
        ),
        RouteInfo(
          id: 'rota_padrao_3',
          name: 'Rota 3 - Ônibus C',
          origin: 'Cidade Nova - R. João Marcos P. Carvalho',
          destination: 'IFS Campus Lagarto',
          estimatedTime: '35 minutos',
          geoJsonIndex: 2,
          createdBy: createdBy,
        ),
      ];

      final batch = FirebaseFirestore.instance.batch();
      for (final rota in rotasPadrao) {
        batch.set(_col.doc(rota.id), rota.toMap());
      }
      await batch.commit();

      debugPrint('[RotaRepository] ✅ 3 rotas padrão migradas para o Firestore.');
    } catch (e) {
      debugPrint('[RotaRepository] Erro na migração: $e');
    }
  }
}
