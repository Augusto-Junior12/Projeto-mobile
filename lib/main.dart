import 'package:flutter/material.dart';
import 'package:projeto_app/telas/telaLogin.dart';
import 'package:projeto_app/services/notification_service.dart';
import 'package:projeto_app/services/map_route_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa os serviços Singleton antes de rodar o app
  await NotificationService().init();
  await MapRouteService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key

});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Telalogin(),
    );
  }
}
