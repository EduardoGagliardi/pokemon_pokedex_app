import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // Navigate to Favorites screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              // Show team overlay
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('List of Pokémon Generations goes here'),
      ),
    );
  }
}
