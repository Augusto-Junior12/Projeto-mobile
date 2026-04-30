import 'package:flutter/material.dart';
import 'package:projeto_app/services/map_route_service.dart';

/// Widget reutilizável que representa um item de rota na lista.
/// Exibe nome, origem/destino e um botão de exclusão.
class RouteListItem extends StatelessWidget {
  final RouteInfo route;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RouteListItem({
    super.key,
    required this.route,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.directions_bus,
          color: route.hasGeoData ? Colors.indigo : Colors.grey,
        ),
        title: Text(route.name),
        subtitle: Text(
          '${route.origin} → ${route.destination}\nTempo: ${route.estimatedTime}',
        ),
        isThreeLine: true,
        trailing: DeleteRouteButton(onDelete: onDelete),
        onTap: onTap,
      ),
    );
  }
}

/// Botão de exclusão de rota reutilizável.
class DeleteRouteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteRouteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      tooltip: 'Excluir rota',
      onPressed: onDelete,
    );
  }
}
