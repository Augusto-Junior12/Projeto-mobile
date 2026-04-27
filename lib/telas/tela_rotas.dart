import 'package:flutter/material.dart';
import 'package:projeto_app/components/item_rota.dart';
import 'package:projeto_app/utils/componentes.dart'; 

class TelaRotas extends StatefulWidget {
  const TelaRotas({super.key});

  @override
  State<TelaRotas> createState() => _TelaRotasState();
}

class _TelaRotasState extends State<TelaRotas> {
  // Array de dados
  final List<Map<String, dynamic>> _listaRotas = [
    {
      'id': '1',
      'titulo': 'Centro',
      'subtitulo': 'Centro -> Ifs',
      'horario': '07:30',
    },
    {
      'id': '2',
      'titulo': 'Sul',
      'subtitulo': 'Sul -> Ifs',
      'horario': '08:00',
    },
  ];

  // Função para abrir o formulário
  void _mostrarFormulario({Map<String, dynamic>? rotaAtual, int? index}) {
    final bool isEdicao = rotaAtual != null;
    
    String origemInicial = '';
    String destinoInicial = '';
    
    if (isEdicao) {
      // Divide a string pelo separador " -> "
      List<String> partes = rotaAtual['subtitulo'].split(' -> ');
      origemInicial = partes.isNotEmpty ? partes[0] : '';
      destinoInicial = partes.length > 1 ? partes[1] : '';
    }

    final _tituloController = TextEditingController(text: isEdicao ? rotaAtual['titulo'] : '');
    final _origemController = TextEditingController(text: origemInicial);
    final _destinoController = TextEditingController(text: destinoInicial);
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
            left: 20, right: 20, top: 20,
          ),
          child: Form(
            key: _formKey, // Validação de formulário
            child: SingleChildScrollView(
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
                    decoration: const InputDecoration(labelText: 'Nome da Rota (ex: Linha Norte)', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Informe o nome da rota' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  TextFormField(
                    controller: _origemController,
                    decoration: const InputDecoration(labelText: 'Local de Saída', border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on_outlined)),
                    validator: (v) => v!.isEmpty ? 'Informe a origem' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  TextFormField(
                    controller: _destinoController,
                    decoration: const InputDecoration(labelText: 'Local de Chegada', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag_outlined)),
                    validator: (v) => v!.isEmpty ? 'Informe o destino' : null,
                  ),
                  const SizedBox(height: 15),
                  
                  TextFormField(
                    controller: _horarioController,
                    decoration: const InputDecoration(labelText: 'Horário previsto', border: OutlineInputBorder(), prefixIcon: Icon(Icons.access_time)),
                    validator: (v) => v!.isEmpty ? 'Informe o horário' : null,
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
                            // Concatenamos origem e destino para salvar como subtitulo
                            String trajetoCompleto = "${_origemController.text} -> ${_destinoController.text}";

                            if (isEdicao) {
                              _listaRotas[index!] = {
                                'id': rotaAtual['id'],
                                'titulo': _tituloController.text,
                                'subtitulo': trajetoCompleto,
                                'horario': _horarioController.text,
                              };
                            } else {
                              _listaRotas.add({
                                'id': DateTime.now().toString(),
                                'titulo': _tituloController.text,
                                'subtitulo': trajetoCompleto,
                                'horario': _horarioController.text,
                              });
                            }
                          });
                          
                          Navigator.pop(context); 
                          
                          // Notificação de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isEdicao ? "Rota atualizada!" : "Rota cadastrada com sucesso!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Text(isEdicao ? "Salvar Alterações" : "Adicionar Rota"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Remoção com confirmação
  void _deletarRota(int index) async {
    bool? confirmou = await CaixaDialogo.confirmar(
      context,
      titulo: "Excluir Rota",
      mensagem: "Tem certeza que deseja remover esta rota?",
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
      body: Column(
        children: [
          // Contador de itens
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            color: Colors.indigo.withValues(alpha: 0.1),
            child: Text(
              'Total de rotas ativas: ${_listaRotas.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              textAlign: TextAlign.center,
            ),
          ),
          
          Expanded(
            child: _listaRotas.isEmpty
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
                        aoEditar: () => _mostrarFormulario(rotaAtual: rota, index: index),
                        aoRemover: () => _deletarRota(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(), 
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}