import 'package:flutter/material.dart';
import 'package:projeto_app/telas/telaHome.dart';

// Tela de cadastro, similar à tela de login, mas com campos adicionais para nome e confirmação de senha
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {

  // Controladores para os campos de nome, curso, matrícula, email e senha
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _cadastrar() {
    // Aqui depois você pode salvar no banco/API, mas por enquanto só vamos navegar para a tela Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaHome()),
    );
  }

  // Construímos a interface da tela de cadastro, com campos para nome, email e senha, e um botão para cadastrar
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
        padding: const EdgeInsets.all(20.0),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // Título da tela
            const Text(
              "Criar conta",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),

            const SizedBox(height: 30),

            // Campo de nome
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de curso
            TextField(
              controller: _cursoController,
              decoration: const InputDecoration(
                labelText: "Curso",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de matrícula
            TextField(
              controller: _matriculaController,
              decoration: const InputDecoration(
                labelText: "Matrícula",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Campo de senha
            TextField(
              controller: _senhaController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Senha",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // Botão de cadastrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cadastrar,
                child: const Text("Cadastrar"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}