import 'package:flutter/material.dart';
import 'package:projeto_app/utils/validadores.dart';

// Tela de recuperação de senha, onde o usuário pode digitar seu e-mail para receber um link de redefinição de senha
class TelaEsqueciSenha extends StatefulWidget {
  const TelaEsqueciSenha({super.key});

  @override
  State<TelaEsqueciSenha> createState() => _TelaEsqueciSenhaState();
}

// A tela de recuperação de senha é simples, com um campo para o usuário digitar seu e-mail e um botão para enviar o link de recuperação
class _TelaEsqueciSenhaState extends State<TelaEsqueciSenha> {

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  void _recuperarSenha() {
    if (_formKey.currentState!.validate()) {
      // Aqui depois você pode integrar com Firebase ou API, mas por enquanto só vamos mostrar uma mensagem de sucesso e voltar para a tela de login

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link de recuperação enviado para o e-mail!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // volta para o login
    }
  }

  // Construímos a interface da tela de recuperação de senha, com um campo para o e-mail e um botão para enviar
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

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Título da tela
            const Text(
              "Esqueceu sua senha?",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 50),

            // Texto explicativo
            const Text(
              "Digite seu e-mail e enviaremos um link para redefinir sua senha.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // Campo de e-mail
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: Validadores.validarEmail,
              decoration: InputDecoration(
                labelText: 'E-mail',
                hintText: 'exemplo@email.com',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botão para enviar o link de recuperação
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _recuperarSenha,
                child: const Text("Enviar"),
              ),
            ),

          ],
          ),
        ),
      ),
    );
  }
}