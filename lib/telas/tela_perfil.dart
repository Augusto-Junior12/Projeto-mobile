import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/telas/tela_editar_dados.dart';
import 'package:projeto_app/utils/componentes.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projeto_app/services/biometric_service.dart';

class TelaPerfil extends StatefulWidget {
  final UsuarioModel usuarioLogado;

  const TelaPerfil({super.key, required this.usuarioLogado});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final UsuarioRepository _repository = UsuarioRepository();
  late UsuarioModel _usuario;
  String? _emailBiometriaVinculado;
  bool _carregandoBiometria = true;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuarioLogado;
    _verificarBiometria();
  }

  Future<void> _verificarBiometria() async {
    final emailSalvo = await BiometricService().getEmailVinculado();
    if (mounted) {
      setState(() {
        _emailBiometriaVinculado = emailSalvo;
        _carregandoBiometria = false;
      });
    }
  }

  Future<void> _desvincularBiometria() async {
    final confirmado = await CaixaDialogo.confirmar(
      context,
      titulo: 'Desvincular Biometria',
      mensagem: 'Tem certeza que deseja remover o acesso biométrico atual?',
    );

    if (confirmado == true) {
      await BiometricService().desativar();
      await _verificarBiometria(); // Atualiza a tela

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometria desvinculada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _escolherFotoPerfil() async {
    try {
      final resultado = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (resultado != null && resultado.files.single.path != null) {
        final caminhoFoto = resultado.files.single.path!;

        final usuarioAtualizado = _usuario.copyWith(fotoPath: caminhoFoto);

        await _repository.atualizar(usuarioAtualizado);

        setState(() {
          _usuario = usuarioAtualizado;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto de perfil atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAvatar() {
    final fotoPath = _usuario.fotoPath;
    if (fotoPath != null && File(fotoPath).existsSync()) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: FileImage(File(fotoPath)),
      );
    }
    return const CircleAvatar(
      radius: 60,
      backgroundColor: Colors.white,
      child: Icon(Icons.person, size: 80, color: Colors.indigo),
    );
  }

  void _mostrarDialogoAvaliacao(BuildContext context) {
    int estrelasSelecionadas = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                'Avaliar UniGo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'O que você está achando do nosso app de transporte estudantil?',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrelasSelecionadas
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setState(() => estrelasSelecionadas = index + 1);
                        },
                      );
                    }),
                  ),
                ],
              ),
              actionsAlignment: MainAxisAlignment.spaceAround,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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

  Future<void> _confirmarSaida(BuildContext context) async {
    final confirmado = await CaixaDialogo.confirmar(
      context,
      titulo: 'Tem certeza?',
      mensagem: 'Você deseja realmente sair da sua conta?',
    );

    if (confirmado == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  Future<void> _irParaEdicao(BuildContext context) async {
    final usuarioAtualizado = await Navigator.push<UsuarioModel>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEditarDados(usuario: _usuario),
      ),
    );

    if (usuarioAtualizado != null) {
      setState(() => _usuario = usuarioAtualizado);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.indigo, width: 3),
                      ),
                      child: _buildAvatar(),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _escolherFotoPerfil,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.indigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _usuario.nome,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _usuario.isCriador ? Colors.indigo.shade700 : Colors.green.shade600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _usuario.isCriador ? 'CRIADOR' : 'LEITOR',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  _usuario.curso,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                Text(
                  'RA: ${_usuario.matricula}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  _usuario.email,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Geral',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.edit, color: Colors.indigo),
            title: const Text('Editar dados'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
            onTap: () => _irParaEdicao(context),
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.amber),
            title: const Text('Avaliar app'),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
            onTap: () => _mostrarDialogoAvaliacao(context),
          ),
          
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Segurança',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Divider(height: 1),

          if (!_carregandoBiometria && _emailBiometriaVinculado != null)
            ListTile(
              leading: const Icon(Icons.fingerprint, color: Colors.orange),
              title: const Text('Desvincular Biometria'),
              subtitle: Text('Vinculado a: $_emailBiometriaVinculado'),
              trailing: const Icon(
                Icons.link_off,
                size: 18,
                color: Colors.orange,
              ),
              onTap: _desvincularBiometria,
            )
          else if (!_carregandoBiometria && _emailBiometriaVinculado == null)
            const ListTile(
              leading: Icon(Icons.fingerprint, color: Colors.grey),
              title: Text('Biometria não ativada', style: TextStyle(color: Colors.grey)),
            ),

          const Divider(height: 1),
          const SizedBox(height: 30),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => _confirmarSaida(context),
          ),
        ],
      ),
    );
  }
}
