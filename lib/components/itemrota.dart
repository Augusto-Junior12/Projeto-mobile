import 'package:flutter/material.dart';

class ItemRota extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final String horario;
  final VoidCallback aoEditar;
  final VoidCallback aoRemover;

  const ItemRota({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.horario,
    required this.aoEditar,
    required this.aoRemover,
  });

  // Widget que representa cada item de rota na lista
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_bus, color: Colors.indigo),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(subtitulo),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  horario,
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ],
            )
          ],
        ),
        // Menu de opções (Editar / Remover)
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            if (valor == 'editar') aoEditar();
            if (valor == 'remover') aoRemover();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.indigo),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remover',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remover', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}