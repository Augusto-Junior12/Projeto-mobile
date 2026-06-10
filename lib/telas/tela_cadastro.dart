import 'package:flutter/material.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/utils/validadores.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';

// Tela de cadastro — salva o novo usuário no SQLite via UsuarioRepository
class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final _formKey = GlobalKey<FormState>();
  final UsuarioRepository _repository = UsuarioRepository();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cursoController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _erroBanco;

  String? _validarCurso(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu curso';
    return null;
  }

  String? _validarMatricula(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Matrícula obrigatória';
    return null;
  }

  // Salva o usuário no SQLite e navega para a tela de login
  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erroBanco = null;
    });

    try {
      // Verifica se o e-mail já está em uso
      final emailLivre = await _repository.emailDisponivel(
        _emailController.text.trim(),
      );

      if (!emailLivre) {
        setState(() => _erroBanco = 'Este e-mail já está cadastrado.');
        return;
      }

      final novoUsuario = UsuarioModel(
        nome: _nomeController.text.trim(),
        curso: _cursoController.text.trim(),
        matricula: _matriculaController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      await _repository.cadastrar(novoUsuario);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso! Faça seu login.'),
          backgroundColor: Colors.green,
        ),
      );

      // Volta para a tela de login após cadastrar
      Navigator.pop(context);
    } catch (e) {
      setState(() => _erroBanco = 'Erro ao cadastrar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
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

              // Nome
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

              // Curso
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

              // Matrícula
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

              // E-mail
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

              // Senha
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

              // Mensagem de erro do banco
              if (_erroBanco != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erroBanco!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
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