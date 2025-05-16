import 'package:flutter/material.dart';
import '../models/generation.dart';

class DisplayGenerationWidget extends StatelessWidget {
  final Generation generation;
  final VoidCallback onTap;

  const DisplayGenerationWidget({
    super.key,
    required this.generation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Génération ${generation.id}: ${generation.name}'),
        subtitle: Text('Région: ${generation.region}'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}