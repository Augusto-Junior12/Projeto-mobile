import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Serviço Singleton para gerenciar notificações locais do UniGo.
/// Utiliza flutter_local_notifications para alertas visuais e sonoros.
class NotificationService {
  // ── Singleton ──────────────────────────────────────────────────────────
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Inicialização ──────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    // Se estiver rodando na web, Windows ou Linux, o plugin não suporta por padrão
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      _initialized = true;
      debugPrint('[NotificationService] Notificações ignoradas para esta plataforma.');
      return;
    }

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(settings);

      // Solicita permissão de notificação no Android 13+
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _initialized = true;
      debugPrint('[NotificationService] Inicializado com sucesso.');
    } catch (e) {
      debugPrint('[NotificationService] Erro ao inicializar notificações: $e');
    }
  }

  // ── Notificação: Rota carregada ────────────────────────────────────────
  Future<void> showRouteLoadedNotification(String routeName) async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint('[NotificationService] showRouteLoadedNotification ignorado no Windows/Linux/Web.');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'unigo_route_channel',
        'Rotas',
        channelDescription: 'Notificações de rotas carregadas',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.show(
        0,
        'Rota Carregada! 🚌',
        'A rota "$routeName" foi carregada com sucesso. Vá ao Mapa para visualizar.',
        details,
      );
    } catch (e) {
      debugPrint('[NotificationService] Erro ao exibir notificação de rota: $e');
    }
  }

  // ── Notificação: Chegada na faculdade (Geofencing) ─────────────────────
  Future<void> showArrivalNotification() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      debugPrint('[NotificationService] showArrivalNotification ignorado no Windows/Linux/Web.');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'unigo_geofence_channel',
        'Geofencing',
        channelDescription: 'Notificações de chegada à faculdade',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.show(
        1,
        'Você chegou! 🎓',
        'Você está a menos de 200m do IFS Campus Lagarto. Bons estudos!',
        details,
      );
    } catch (e) {
      debugPrint('[NotificationService] Erro ao exibir notificação de chegada: $e');
    }
  }
}
