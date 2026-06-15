import 'package:flutter/material.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/telas/tela_mapa.dart';
import 'package:projeto_app/telas/tela_rotas.dart';
import 'package:projeto_app/telas/tela_perfil.dart';

class TelaHome extends StatefulWidget {
  final UsuarioModel usuarioLogado;

  const TelaHome({super.key, required this.usuarioLogado});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome> {
  int _abaSelecionada = 0;

  Widget _getTelaSelecionada() {
    switch (_abaSelecionada) {
      case 0:
        return const TelaMapa();
      case 1:
        return TelaRotas(onIrParaMapa: () => setState(() => _abaSelecionada = 0));
      case 2:
        return TelaPerfil(usuarioLogado: widget.usuarioLogado);
      default:
        return const Center(
          child: Text(
            'Tela não encontrada',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'UniGo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),

      body: _getTelaSelecionada(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: (indice) {
          setState(() => _abaSelecionada = indice);
        },
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: 'Rotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
