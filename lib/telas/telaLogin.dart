import 'package:flutter/material.dart';
import 'package:projeto_app/telas/telaHome.dart';
import 'package:projeto_app/telas/telaEsqueciSenha.dart';
import 'package:projeto_app/telas/telaCadastro.dart';

// 1. Criamos a tela de login como um StatefulWidget para poder controlar os campos de texto e a navegação
class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  // 2. Criamos controladores para os campos de email e senha, para poder ler o que o usuário digitou
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  // 3. Criamos uma função para ser chamada quando o usuário clicar no botão "Entrar". Por enquanto, ela só navega para a tela Home, mas aqui é onde pode adicionar a lógica de autenticação.
  void _entrar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaHome()),
    );
  }

  // 4. Construímos a interface da tela de login, com campos para email e senha, e um botão para entrar
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
          20.0
          ), // Adiciona um pouco de espaço ao redor do conteúdo

        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .center, // Centraliza o conteúdo verticalmente
          children: [

            const Text(
              "UniGo",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors
                    .indigo, // Deixa o texto do título com a mesma cor do AppBar
              ),
            ),

            const SizedBox(
              height: 60
              ), // Adiciona um espaço entre o título e os campos de texto

            TextField( // Campo E-mail
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField( // Campo Senha
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            // Link "Esqueci minha senha" alinhado à direita
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaEsqueciSenha()),
                  );
                },
                child: const Text("Esqueci minha senha"),
              ),
            ),

            const SizedBox(height: 30), // Adiciona um espaço entre os campos de texto e o botão

            SizedBox( // Botão Entrar
              width: double.infinity, // Faz o botão ocupar toda a largura disponível
              child: ElevatedButton(
                onPressed: _entrar,
                child: const Text("Entrar"),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaCadastro()),
                );
              },
              child: const Text("Não tem conta? Cadastre-se"),
            ),
          ],
        ), 
      ),
    );
  }
}