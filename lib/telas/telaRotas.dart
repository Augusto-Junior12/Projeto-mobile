import 'package:flutter/material.dart';
import 'package:projeto_app/components/itemrota.dart'; 
import 'package:projeto_app/utils/componentes.dart';

class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  // Nossa lista de rotas (Simulando um banco de dados temporário)
  final List<Map<String, dynamic>> _listaRotas = [
    {
      'id': '1',
      'titulo': 'Rota A - Centro',
      'subtitulo': 'Saída: Praça da caixa d\'agua -> IFS',
      'horario': '07:30',
    },
    {
      'id': '2',
      'titulo': 'Rota B - Sul',
      'subtitulo': 'Saída: Bairro Sul -> IFS',
      'horario': '08:00',
    },
  ];

  // Função para abrir o modal de Adicionar ou Editar
  void _mostrarFormulario({Map<String, dynamic>? rotaAtual, int? index}) {
    final bool isEdicao = rotaAtual != null;
    
    // Controladores preenchidos se for edição, vazios se for novo
    final _tituloController = TextEditingController(text: isEdicao ? rotaAtual['titulo'] : '');
    final _subtituloController = TextEditingController(text: isEdicao ? rotaAtual['subtitulo'] : '');
    final _horarioController = TextEditingController(text: isEdicao ? rotaAtual['horario'] : '');

    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdicao ? "Editar Rota" : "Nova Rota",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(labelText: 'Título da Rota', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _subtituloController,
                  decoration: const InputDecoration(labelText: 'Trajeto (Ex: Ponto A -> Ponto B)', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _horarioController,
                  decoration: const InputDecoration(labelText: 'Horário (Ex: 08:00)', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          if (isEdicao) {
                            // Atualiza item existente
                            _listaRotas[index!] = {
                              'id': rotaAtual['id'],
                              'titulo': _tituloController.text,
                              'subtitulo': _subtituloController.text,
                              'horario': _horarioController.text,
                            };
                          } else {
                            // Cria novo item
                            _listaRotas.add({
                              'id': DateTime.now().toString(), // ID único temporário
                              'titulo': _tituloController.text,
                              'subtitulo': _subtituloController.text,
                              'horario': _horarioController.text,
                            });
                          }
                        });
                        Navigator.pop(context); // Fecha o modal
                      }
                    },
                    child: Text(isEdicao ? "Salvar Alterações" : "Adicionar Rota"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Função para deletar com o seu AlertDialog reutilizável
  void _deletarRota(int index) async {
    bool? confirmou = await CaixaDialogo.confirmar(
      context,
      titulo: "Excluir Rota",
      mensagem: "Tem certeza que deseja remover esta rota permanentemente?",
    );

    if (confirmou == true) {
      setState(() {
        _listaRotas.removeAt(index);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Rota removida com sucesso!"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ListView.builder renderiza a lista dinamicamente
      body: _listaRotas.isEmpty
          ? const Center(child: Text("Nenhuma rota cadastrada."))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _listaRotas.length,
              itemBuilder: (context, index) {
                final rota = _listaRotas[index];
                return ItemRota(
                  titulo: rota['titulo'],
                  subtitulo: rota['subtitulo'],
                  horario: rota['horario'],
                  // Passamos as funções para o componente
                  aoEditar: () => _mostrarFormulario(rotaAtual: rota, index: index),
                  aoRemover: () => _deletarRota(index),
                );
              },
            ),
      
      // Botão Flutuante para Adicionar
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}