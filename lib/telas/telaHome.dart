import 'package:flutter/material.dart';

// 1. Mudamos para StatefulWidget para o menu poder interagir
class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  // 2. Criamos uma variável para guardar qual aba está selecionada (começa no 0, que é a primeira)
  int _abaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'UniGo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ), // Deixa o nome mais destacado
        ),
        centerTitle: true, // Centraliza o título
        backgroundColor: Colors.indigo, // Cor de fundo do AppBar
        foregroundColor: Colors.white, // Deixa o texto do título branco para dar contraste
        elevation: 4, // Adiciona uma leve sombra embaixo do AppBar
      ),

      body: Padding(
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
      ),

      // 3. A mágica acontece aqui: O Menu Inferior!
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada, // Diz ao menu qual aba deve ficar acesa
        
        onTap: (indice) {
          // Quando clica num botão, ele atualiza a tela
          setState(() {
            _abaSelecionada = indice;
          });
        },

        selectedItemColor: Colors.indigo, // Cor do botão clicado
        unselectedItemColor: Colors.grey, // Cor dos botões inativos
        
        items: const [

          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: 'Mapa',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.directions_bus,
            ), // Ícone de ônibus para rotas
            label: 'Rotas',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Perfil',
          ),

        ],
      ),

    );
  }
}