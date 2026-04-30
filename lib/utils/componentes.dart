import 'package:flutter/material.dart';

// Alerta de confirmação genérico reutilizável para toda a aplicação
class CaixaDialogo {
  static Future<bool?> confirmar(
    BuildContext context, {
    String titulo = "Tem certeza?",
    String mensagem = "Deseja realizar esta ação?",
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            titulo,
            style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
          ),
          content: Text(mensagem),
          actions: [
            // Botão NÃO
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não", style: TextStyle(color: Colors.grey)),
            ),
            // Botão SIM
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Sim"),
            ),
          ],
        );
      },
    );
  }
}