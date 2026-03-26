import 'package:flutter/material.dart';

// 1. Criamos a tela do mapa como um StatefulWidget para poder adicionar interatividade no futuro
class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

// 2. O estado da tela do mapa, onde vamos construir a interface
class _TelaMapaState extends State<TelaMapa> {
  @override
  // 3. Construímos a interface da tela do mapa, com um campo para digitar a localização e um mapa (que por enquanto é só uma imagem de fundo)
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(
          16.0,
        ), // Adiciona um pouco de espaço ao redor do conteúdo

        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Estica o conteúdo para ocupar toda a largura disponível
          children: [

            const Text(
              'Olá, estudante!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors
                    .indigo, // Deixa o texto do título com a mesma cor do AppBar
              ),
              textAlign: TextAlign.center, // Centraliza o texto
            ),

            const SizedBox(
              height: 20,
            ), // Adiciona um espaço entre o título e o conteúdo

            const Text(
              'Encontre a rota mais rápida para a faculdade.',
              style: TextStyle(
                fontSize: 16,
                color: Colors
                    .black87, // Deixa o texto com uma cor mais suave para leitura
              ),
              textAlign: TextAlign.center, // Centraliza o texto
            ),

            const SizedBox(
              height: 30,
            ), // Adiciona um espaço entre o texto e o campo

            TextField(
              decoration: InputDecoration(
                labelText:
                    'Digite sua localização atual', // Texto de dica para o usuário
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    8,
                  ), // Deixa as bordas do campo arredondadas
                ),
                prefixIcon: const Icon(
                  Icons.location_on,
                ), // Adiciona um ícone de localização no início do campo
              ),
            ),

            const SizedBox(
              height: 20,
            ), // Adiciona um espaço entre o campo de texto e o mapa

            // O Mapa
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[100], // Cor de fundo
                  borderRadius: BorderRadius.circular(
                    16,
                  ), // Deixa as bordas do mapa arredondadas
                  image: const DecorationImage(
                    image: NetworkImage(
                        'https://tile.openstreetmap.org/14/6504/8691.png'), // URL de Aracaju
                    fit: BoxFit.cover, // Faz a imagem cobrir todo o espaço
                    opacity: 0.8, // Deixa a imagem um pouco transparente
                  ),
                ),

                child: const Center(
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: Colors.indigo, // Cor do ícone
                  ),
                ),

              ),
            ),

          ],
        ),
    );
  }
}