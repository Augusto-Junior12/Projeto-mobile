import 'package:flutter/material.dart';

class TelaEditarDados extends StatefulWidget {
  const TelaEditarDados({super.key});

  @override
  State<TelaEditarDados> createState() => _TelaEditarDadosState();
}

class _TelaEditarDadosState extends State<TelaEditarDados> {
  // 1. Controladores para ler e editar o texto dos campos
  // Já colocamos o texto inicial para simular os dados vindos do banco
  final TextEditingController _nomeController = TextEditingController(text: 'Aluno de mobile');
  final TextEditingController _cursoController = TextEditingController(text: 'Sistemas de Informação');
  final TextEditingController _raController = TextEditingController(text: '12345678');

  // 2. Função para salvar os dados e voltar
  void _salvarDados() {
    // No futuro, aqui entrará o código para salvar no banco de dados (API)
    
    // Depois de salvar, voltamos para a tela de perfil
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    // É boa prática limpar os controladores quando a tela é fechada
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
        padding: const EdgeInsets.all(20.0), // Mesmo padrão de espaçamento
        child: Column(
          children: [
            
            // Campo Nome
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: "Nome Completo",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person), // Ícone bonitinho no campo
              ),
            ),
            
            const SizedBox(height: 20),

            // Campo Curso
            TextField(
              controller: _cursoController,
              decoration: const InputDecoration(
                labelText: "Curso",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.school),
              ),
            ),
            
            const SizedBox(height: 20),

            // Campo RA (Matrícula)
            TextField(
              controller: _raController,
              keyboardType: TextInputType.number, // Abre o teclado numérico
              decoration: const InputDecoration(
                labelText: "RA (Matrícula)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            
            const SizedBox(height: 40),

            // Botão Salvar
            SizedBox(
              width: double.infinity, // Ocupa a largura toda, igual no Login
              height: 50, // Deixa o botão um pouco mais alto e confortável de clicar
              child: ElevatedButton(
                onPressed: _salvarDados,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Salvar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}