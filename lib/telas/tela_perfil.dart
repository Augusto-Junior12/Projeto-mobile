import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_editar_dados.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  // Pop-up de Avaliação
  void _mostrarDialogoAvaliacao(BuildContext context) {
    int estrelasSelecionadas = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Avaliar UniGo',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'O que você está achando do nosso app de transporte estudantil?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrelasSelecionadas ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() {
                            estrelasSelecionadas = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Obrigado pela sua avaliação!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Pop-up de confirmação de Saída ─────────────────────────────────────
  void _confirmarSaida(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Tem certeza?',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
          ),
          content: const Text('Você deseja realmente sair da sua conta?'),
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            // Botão Não
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Não',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            // Botão Sim
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // fecha o dialog
                Navigator.pushReplacementNamed(context, '/'); // volta ao login
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // 1. Cabeçalho de Identidade (Foto e Dados Básicos)
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.indigo, width: 3),
                  ),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 80, color: Colors.indigo),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Aluno de Mobile',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Sistemas de Informação',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const Text(
                  'RA: 12345678',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Divider(),

          // 2. Lista de Ações (Menu)

          // Botão: Editar Dados
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.indigo),
            title: const Text('Editar dados'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaEditarDados()),
              );
            },
          ),
          const Divider(height: 1),

          // Botão: Avaliar App
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.amber),
            title: const Text('Avaliar app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () => _mostrarDialogoAvaliacao(context),
          ),
          const Divider(height: 1),

          // Botão: Sair — agora com confirmação
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _confirmarSaida(context), // ← abre o dialog de confirmação
          ),
        ],
      ),
    );
  }
}