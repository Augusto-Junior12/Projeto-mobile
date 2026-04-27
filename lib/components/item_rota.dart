import 'package:flutter/material.dart';
import 'package:projeto_app/components/botao_remover.dart';

// Componente reutilizável para construir cada item da lista
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
        // Aqui deixamos as opções mais visíveis e usamos o componente exigido
        trailing: Row(
          mainAxisSize: MainAxisSize.min, // Ocupa apenas o espaço necessário
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.indigo),
              tooltip: 'Editar',
              onPressed: aoEditar,
            ),
            BotaoRemover(aoPressionar: aoRemover),
          ],
        ),
      ),
    );
  }
}