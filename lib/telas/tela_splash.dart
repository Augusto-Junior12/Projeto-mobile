import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/services/map_route_service.dart';
import 'package:projeto_app/services/biometric_service.dart';
import 'package:projeto_app/telas/tela_home.dart';
import 'package:projeto_app/telas/tela_login.dart';

/// Tela de splash que decide o fluxo de entrada:
/// 1. Se há sessão ativa no Firebase → verifica biometria → TelaHome
/// 2. Se não há sessão → TelaLogin
class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  String _status = 'Carregando...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    // Pequeno delay para a animação aparecer
    await Future.delayed(const Duration(milliseconds: 600));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _irParaLogin();
      return;
    }

    // Usuário logado → verificar biometria
    final biometric = BiometricService();
    final biometriaAtivada = await biometric.estaAtivada();

    if (biometriaAtivada) {
      if (mounted) setState(() => _status = 'Verificando identidade...');

      final autenticado = await biometric.autenticar();
      if (!autenticado) {
        // Biometria falhou → mandar para login manual
        _irParaLogin();
        return;
      }
    }

    // Buscar dados do usuário no Firestore
    if (mounted) setState(() => _status = 'Preparando tudo...');

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        // Documento não existe — sessão corrompida
        await FirebaseAuth.instance.signOut();
        _irParaLogin();
        return;
      }

      final usuario = UsuarioModel.fromMap(doc.data()!);

      // Carregar rotas do Firestore
      await MapRouteService().loadAllRoutes();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TelaHome(usuarioLogado: usuario),
        ),
      );
    } catch (e) {
      debugPrint('[TelaSplash] Erro ao recuperar sessão: $e');
      _irParaLogin();
    }
  }

  void _irParaLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Telalogin()),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // indigo 900
              Color(0xFF3949AB), // indigo 600
              Color(0xFF5C6BC0), // indigo 400
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo / Ícone
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'UniGo',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Transporte universitário inteligente',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 48),

              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _status,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
