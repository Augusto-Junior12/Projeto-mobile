import 'package:flutter/material.dart';
import 'package:projeto_app/telas/telaEditardados.dart'; 

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  // Função que cria e mostra o Pop-up de Avaliação
  void _mostrarDialogoAvaliacao(BuildContext context) {
    int estrelasSelecionadas = 0; // Começa com zero estrelas

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder permite que a gente mude o estado (acenda as estrelas) só dentro do pop-up
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
                mainAxisSize: MainAxisSize.min, // Faz a caixa ficar do tamanho exato do conteúdo
                children: [
                  const Text(
                    'O que você está achando do nosso app de transporte estudantil?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Linha com as 5 estrelas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrelasSelecionadas ? Icons.star : Icons.star_border,
                          color: Colors.amber, // Cor amarelinha clássica de avaliação
                          size: 36,
                        ),
                        onPressed: () {
                          // Ao clicar, atualiza a quantidade de estrelas acesas
                          setState(() {
                            estrelasSelecionadas = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceAround, // Separa os botões
              actions: [
                // Botão de Cancelar
                TextButton(
                  onPressed: () => Navigator.pop(context), // Fecha o pop-up
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                // Botão de Enviar
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha o pop-up
                    // Mostra um aviso rápido na parte de baixo da tela agradecendo
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
                  'Aluno de mobile',
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
            leading: const Icon(Icons.star_rate, color: Colors.amber), // Mudei a cor da estrelinha do menu para dar um charme
            title: const Text('Avaliar app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () {
              // AQUI NÓS CHAMAMOS A NOSSA FUNÇÃO DO POP-UP!
              _mostrarDialogoAvaliacao(context);
            },
          ),
          const Divider(height: 1),

          // Botão: Sair 
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/'); 
            },
          ),
        ],
      ),
    );
  }
}