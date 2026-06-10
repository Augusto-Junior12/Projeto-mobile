import 'package:flutter/material.dart';
import 'package:projeto_app/models/usuario_model.dart';
import 'package:projeto_app/repositories/usuario_repository.dart';

// TelaEditarDados — edita nome, curso e matrícula e persiste no Firestore
class TelaEditarDados extends StatefulWidget {
  final UsuarioModel usuario;

  const TelaEditarDados({super.key, required this.usuario});

  @override
  State<TelaEditarDados> createState() => _TelaEditarDadosState();
}

class _TelaEditarDadosState extends State<TelaEditarDados> {
  late final TextEditingController _nomeController;
  late final TextEditingController _cursoController;
  late final TextEditingController _raController;

  final UsuarioRepository _repository = UsuarioRepository();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    // Pré-preenche os campos com os dados reais do usuário
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _cursoController = TextEditingController(text: widget.usuario.curso);
    _raController = TextEditingController(text: widget.usuario.matricula);
  }

  // Salva as alterações no Firestore e retorna o usuário atualizado para TelaPerfil
  Future<void> _salvarDados() async {
    final nomeTrimado = _nomeController.text.trim();
    final cursoTrimado = _cursoController.text.trim();
    final raTrimado = _raController.text.trim();

    if (nomeTrimado.isEmpty || cursoTrimado.isEmpty || raTrimado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos antes de salvar.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _carregando = true);

    try {
      // Cria cópia do usuário com os campos editados
      final usuarioAtualizado = widget.usuario.copyWith(
        nome: nomeTrimado,
        curso: cursoTrimado,
        matricula: raTrimado,
      );

      await _repository.atualizar(usuarioAtualizado);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados atualizados com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Retorna o usuário atualizado para TelaPerfil via Navigator.pop
      Navigator.pop(context, usuarioAtualizado);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cursoController.dispose();
    _raController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Dados',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Campo Nome
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 20),

            // Campo Curso
            TextField(
              controller: _cursoController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Curso',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),

            const SizedBox(height: 20),

            // Campo RA (Matrícula)
            TextField(
              controller: _raController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'RA (Matrícula)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),

            const SizedBox(height: 40),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _carregando ? null : _salvarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
                        'Salvar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}