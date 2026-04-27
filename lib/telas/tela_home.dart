import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_mapa.dart';
import 'package:projeto_app/telas/tela_rotas.dart';
import 'package:projeto_app/telas/tela_perfil.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

// Sistema para decidir qual tela mostrar com base na aba selecionada
class _TelaHomeState extends State<TelaHome> {
  int _abaSelecionada = 0;

  Widget _getTelaSelecionada() {
    switch (_abaSelecionada) {
      case 0:
        return const TelaMapa();
      case 1:
        return const TelaRotas();
      case 2:
        return const TelaPerfil();
      default:
        return const Center(child: Text('Tela não encontrada'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta o botão "voltar" físico ou por gestos do celular
    return PopScope(
      canPop: _abaSelecionada == 0, // Só permite fechar a tela se estiver na aba 0
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Se não estiver na aba Mapa, volta para ela em vez de sair
        setState(() {
          _abaSelecionada = 0;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'UniGo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 4,
        ),
        body: _getTelaSelecionada(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _abaSelecionada,
          onTap: (indice) {
            setState(() {
              _abaSelecionada = indice;
            });
          },
          selectedItemColor: Colors.indigo,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
            BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Rotas'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}