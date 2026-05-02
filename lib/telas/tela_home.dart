import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_mapa.dart';
import 'package:projeto_app/telas/tela_rotas.dart';
import 'package:projeto_app/telas/tela_perfil.dart';

// 1. Mudamos para StatefulWidget para o menu poder interagir
class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  // 2. Criamos uma variável para guardar qual aba está selecionada (começa no 0, que é a primeira)
  int _abaSelecionada = 0;

  Widget _getTelaSelecionada() {
    // Essa função retorna a tela que deve ser mostrada de acordo com a aba selecionada
    switch (_abaSelecionada) {
      case 0:
        return const TelaMapa(); // Tela do mapa
      case 1:
        return const TelaRotas(); // Tela das rotas
      case 2:
        return const TelaPerfil(); // 2. MUDANÇA AQUI: Chama a tela de perfil real
      default:
        return const Center(
          child: Text(
            'Tela não encontrada',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ); // Caso algo dê errado, mostra uma mensagem de erro
    }
  }

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
        automaticallyImplyLeading: false, // Remove a seta de voltar
      ),

      body: _getTelaSelecionada(), // Mostra a tela de acordo com a aba selecionada

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