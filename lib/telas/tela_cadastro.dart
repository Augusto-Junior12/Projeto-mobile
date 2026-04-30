import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_home.dart';
import 'package:projeto_app/utils/validadores.dart';

// Tela de cadastro — usa Validadores (utils) do orientador
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _senhaVisivel = false;

  // Validadores específicos do cadastro (curso e matrícula são locais pois não estão em Validadores)
  String? _validarCurso(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu curso';
    return null;
  }

  String? _validarMatricula(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Matrícula obrigatória';
    return null;
  }

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      // Aqui futuramente: salvar no banco/API
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TelaHome()),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cursoController.dispose();
    _matriculaController.dispose();
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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Criar conta",
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Nome — Validadores.validarNome
              TextFormField(
                controller: _nomeController,
                validator: Validadores.validarNome,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // Curso — validador local
              TextFormField(
                controller: _cursoController,
                validator: _validarCurso,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Curso',
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // Matrícula — validador local
              TextFormField(
                controller: _matriculaController,
                validator: _validarMatricula,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  prefixIcon: const Icon(Icons.tag),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // E-mail — Validadores.validarEmail
              TextFormField(
                controller: _emailController,
                validator: Validadores.validarEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 20),

              // Senha — Validadores.validarSenha (mínimo 6 caracteres)
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}