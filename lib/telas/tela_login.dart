import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_home.dart';
import 'package:projeto_app/telas/tela_esqueci_senha.dart';
import 'package:projeto_app/telas/tela_cadastro.dart';
import 'package:projeto_app/utils/validadores.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';
import 'package:projeto_app/models/usuario_model.dart';

// Tela de login — autentica o usuário consultando o SQLite via UsuarioRepository
class Telalogin extends StatefulWidget {
  const Telalogin({super.key});

  @override
  State<Telalogin> createState() => _TelaloginState();
}

class _TelaloginState extends State<Telalogin> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final UsuarioRepository _repository = UsuarioRepository();

  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _erroBanco;

  // Realiza o login consultando o banco de dados
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erroBanco = null;
    });

    try {
      final UsuarioModel? usuario = await _repository.login(
        _emailController.text.trim(),
        _senhaController.text,
      );

      if (!mounted) return;

      if (usuario != null) {
        // Login bem-sucedido: navega para Home passando o usuário logado
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaHome(usuarioLogado: usuario),
          ),
        );
      } else {
        setState(() => _erroBanco = 'E-mail ou senha incorretos.');
      }
    } catch (e) {
      setState(() => _erroBanco = 'Erro ao acessar o banco de dados.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniGo', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
        automaticallyImplyLeading: false,
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "UniGo",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),

                const SizedBox(height: 60),

                // Campo E-mail
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

                const SizedBox(height: 20),

                // Campo Senha
                TextFormField(
                  controller: _senhaController,
                  obscureText: !_senhaVisivel,
                  validator: Validadores.validarSenha,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_senhaVisivel ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Mensagem de erro do banco
                if (_erroBanco != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _erroBanco!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

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
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _entrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _carregando
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
      ),
    );
  }
}