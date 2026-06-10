import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/telas/tela_editar_dados.dart';
import 'package:projeto_app/utils/componentes.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';

// TelaPerfil — exibe os dados reais do usuário logado vindos do SQLite e gerencia a foto de perfil
class TelaPerfil extends StatefulWidget {
  final UsuarioModel usuarioLogado;

  const TelaPerfil({super.key, required this.usuarioLogado});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  // Mantém a referência local para atualizar após edição
  late UsuarioModel _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuarioLogado;
  }

  // Seleciona uma imagem do dispositivo e atualiza a foto do perfil
  Future<void> _escolherFotoPerfil() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (resultado != null && resultado.files.single.path != null) {
        final caminhoFoto = resultado.files.single.path!;

        // Cria a cópia com a nova foto de perfil
        final usuarioAtualizado = _usuario.copyWith(fotoPath: caminhoFoto);

        // Atualiza no banco local
        await UsuarioRepository().atualizar(usuarioAtualizado);

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

  // Constrói o widget da foto de perfil, validando se o arquivo físico ainda existe no disco
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

  // Pop-up de Avaliação
  void _mostrarDialogoAvaliacao(BuildContext context) {
    int estrelasSelecionadas = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text(
                'Avaliar UniGo',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
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
                          index < estrelasSelecionadas ? Icons.star : Icons.star_border,
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
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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

  // Confirmação de saída usando CaixaDialogo (utils/componentes.dart)
  Future<void> _confirmarSaida(BuildContext context) async {
    final confirmado = await CaixaDialogo.confirmar(
      context,
      titulo: 'Tem certeza?',
      mensagem: 'Você deseja realmente sair da sua conta?',
    );

    if (confirmado == true && context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  // Navega para edição e atualiza os dados locais ao retornar
  Future<void> _irParaEdicao(BuildContext context) async {
    final usuarioAtualizado = await Navigator.push<UsuarioModel>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaEditarDados(usuario: _usuario),
      ),
    );

    // Se o usuário salvou alterações, atualiza a tela de perfil
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

          // Cabeçalho de Identidade — dados reais do banco + foto editável
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

                Text(
                  _usuario.nome,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
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
          const Divider(),

          // Botão: Editar Dados
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.indigo),
            title: const Text('Editar dados'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () => _irParaEdicao(context),
          ),
          const Divider(height: 1),

          // Botão: Avaliar App
          ListTile(
            leading: const Icon(Icons.star_rate, color: Colors.amber),
            title: const Text('Avaliar app'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            onTap: () => _mostrarDialogoAvaliacao(context),
          ),
          const Divider(height: 1),

          // Botão: Sair
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