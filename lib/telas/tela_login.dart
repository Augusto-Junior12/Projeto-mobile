import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_home.dart';
import 'package:projeto_app/telas/tela_esqueci_senha.dart';
import 'package:projeto_app/telas/tela_cadastro.dart';
import 'package:projeto_app/utils/validadores.dart'; 

class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  // Chave global para identificar e validar o formulário
  final _chaveFormulario = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  void _entrar() {
    // Antes de navegar, verificamos se o formulário é válido
    if (_chaveFormulario.currentState!.validate()) {
      // Se passou na validação, navega para a Home
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TelaHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniGo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 4,
      ),
      body: SingleChildScrollView( // Adicionado para evitar erro de tela pequena com o teclado
        padding: const EdgeInsets.all(20.0),
        
        // Envolvemos a Column com o widget Form e passamos a chave
        child: Form(
          key: _chaveFormulario,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "UniGo",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 60),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "E-mail",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: Validadores.validarEmail, // Chama a função
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _senhaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: Validadores.validarSenha,
              ),
              const SizedBox(height: 10),

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
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50, // Deixa o botão mais alto
                child: ElevatedButton(
                  onPressed: _entrar, // O clique vai chamar a validação agora
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Entrar", style: TextStyle(fontSize: 18)),
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
      ),
    );
  }
}