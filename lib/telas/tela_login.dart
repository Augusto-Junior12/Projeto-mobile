import 'package:flutter/material.dart';
import 'package:projeto_app/telas/tela_home.dart';
import 'package:projeto_app/telas/tela_esqueci_senha.dart';
import 'package:projeto_app/telas/tela_cadastro.dart';
import 'package:projeto_app/utils/validadores.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/services/biometric_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final BiometricService _biometric = BiometricService();

  bool _senhaVisivel = false;
  bool _carregando = false;
  String? _erroBanco;

  // Controla a visibilidade do botão de biometria
  bool _biometriaDisponivel = false;
  bool _biometriaAtivada = false;

  @override
  void initState() {
    super.initState();
    _verificarBiometria();
  }

  /// Verifica se o dispositivo suporta biometria e se o usuário já a ativou.
  Future<void> _verificarBiometria() async {
    final disponivel = await _biometric.disponivel();
    final ativada = await _biometric.estaAtivada();
    if (mounted) {
      setState(() {
        _biometriaDisponivel = disponivel;
        _biometriaAtivada = ativada;
      });
    }
  }

  // ── Login com e-mail e senha ───────────────────────────────────────────────
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
        // Oferece ativar biometria se disponível e ainda não ativada
        if (_biometriaDisponivel && !_biometriaAtivada) {
          await _oferecerAtivacaoBiometria(
            _emailController.text.trim(),
            _senhaController.text,
          );
        }

        await MapRouteService().loadAllRoutes();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaHome(usuarioLogado: usuario),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        setState(() => _erroBanco = 'E-mail ou senha incorretos.');
      } else {
        setState(() => _erroBanco = 'Erro ao fazer login. Tente novamente.');
      }
    } catch (e) {
      setState(() => _erroBanco = 'Erro ao fazer login. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ── Login com biometria ────────────────────────────────────────────────────
  Future<void> _entrarComBiometria() async {
    setState(() {
      _carregando = true;
      _erroBanco = null;
    });

    try {
      // 1. Abre o diálogo de biometria do sistema
      final autenticado = await _biometric.autenticar();
      if (!autenticado) {
        if (mounted) setState(() => _carregando = false);
        return;
      }

      // 2. Recupera as credenciais salvas no armazenamento seguro
      final credenciais = await _biometric.lerCredenciais();
      if (credenciais == null) {
        if (mounted) {
          setState(() {
            _carregando = false;
            _erroBanco = 'Nenhuma credencial salva. Faça login com e-mail e senha.';
            _biometriaAtivada = false;
          });
        }
        return;
      }

      // 3. Autentica no Firebase com as credenciais recuperadas
      final UsuarioModel? usuario = await _repository.login(
        credenciais.email,
        credenciais.senha,
      );

      if (!mounted) return;

      if (usuario != null) {
        await MapRouteService().loadAllRoutes();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TelaHome(usuarioLogado: usuario),
          ),
        );
      }
    } on FirebaseAuthException catch (_) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroBanco = 'Credenciais expiradas. Faça login com e-mail e senha.';
        });
        // Limpa credenciais inválidas para forçar novo login manual
        await _biometric.desativar();
        setState(() => _biometriaAtivada = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _carregando = false;
          _erroBanco = 'Erro na autenticação. Tente novamente.';
        });
      }
    }
  }

  // ── Oferecer ativação da biometria após o primeiro login manual ────────────
  Future<void> _oferecerAtivacaoBiometria(String email, String senha) async {
    if (!mounted) return;

    final ativar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ativar login por biometria?',
          style: TextStyle(
            color: Colors.indigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Nas próximas vezes, você poderá entrar com sua digital ou reconhecimento facial, sem precisar digitar a senha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Agora não', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.fingerprint),
            label: const Text('Ativar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );

    if (ativar == true) {
      await _biometric.salvarCredenciais(email, senha);
      if (mounted) setState(() => _biometriaAtivada = true);
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
                      icon: Icon(
                        _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () =>
                          setState(() => _senhaVisivel = !_senhaVisivel),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Mensagem de erro
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
                        MaterialPageRoute(
                          builder: (context) => const TelaEsqueciSenha(),
                        ),
                      );
                    },
                    child: const Text("Esqueci minha senha"),
                  ),
                ),

                const SizedBox(height: 30),

                // Botão Entrar (e-mail e senha)
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Botão de biometria — aparece apenas se disponível e já ativada
                if (_biometriaDisponivel && _biometriaAtivada) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _carregando ? null : _entrarComBiometria,
                      icon: const Icon(Icons.fingerprint, size: 26),
                      label: const Text(
                        'Entrar com biometria',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: const BorderSide(color: Colors.indigo, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaCadastro(),
                      ),
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