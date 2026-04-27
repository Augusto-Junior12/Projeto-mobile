import 'package:flutter/material.dart';

// Componente Reutilizável focado apenas na ação de deletar
class BotaoRemover extends StatelessWidget {
  final VoidCallback aoPressionar;

  const BotaoRemover({super.key, required this.aoPressionar});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      color: Colors.red, 
      tooltip: 'Remover Rota', 
      onPressed: aoPressionar,
    );
  }
}