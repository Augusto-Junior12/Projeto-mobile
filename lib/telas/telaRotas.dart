import 'package:flutter/material.dart';

// 1. Criamos a tela de rotas como um StatefulWidget para poder adicionar interatividade no futuro
class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  // 2. Construímos a interface da tela de rotas, que por enquanto é uma lista simples de rotas disponíveis
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),

      // 3. Adicionamos um título e uma lista de rotas disponíveis, cada uma com um ícone, nome e tempo estimado
      children: [
        const Text(
          'Rotas Disponíveis',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),

        // 4. Cada rota é representada por um ListTile, que pode ser clicado para mostrar mais detalhes ou iniciar a navegação (a lógica para isso ainda precisa ser implementada)
        ListTile(
          leading: const Icon(Icons.directions_bus, color: Colors.indigo),
          title: const Text('Rota 1 - Ônibus A'),
          subtitle: const Text('Tempo estimado: 30 minutos'),
          onTap: () {
            // Aqui você pode adicionar a lógica para mostrar os detalhes da rota ou iniciar a navegação
          },
        ),

        ListTile(
          leading: const Icon(Icons.directions_bus, color: Colors.indigo),
          title: const Text('Rota 2 - Ônibus B'),
          subtitle: const Text('Tempo estimado: 25 minutos'),
          onTap: () {
            // Aqui você pode adicionar a lógica para mostrar os detalhes da rota ou iniciar a navegação
          },
        ),

        ListTile(
          leading: const Icon(Icons.directions_bus, color: Colors.indigo),
          title: const Text('Rota 3 - Ônibus C'),
          subtitle: const Text('Tempo estimado: 35 minutos'),
          onTap: () {
            // Aqui você pode adicionar a lógica para mostrar os detalhes da rota ou iniciar a navegação
          },
        ),
      ],
    );
  }
}