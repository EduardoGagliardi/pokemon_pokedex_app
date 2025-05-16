import 'package:flutter/material.dart';
import 'package:pokemon_pokedex_app/screens/favorites_screen.dart';
import '../models/generation.dart';
import '../services/api_service.dart';
import '../widgets/display_generation_widget.dart';
import 'generation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Generation>> _generationsFuture;

  @override
  void initState() {
    super.initState();
    _generationsFuture = ApiService.fetchGenerations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(icon: const Icon(Icons.favorite), onPressed: () {
            Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FavoritesScreen(),
                      ),
                    );
          }),
          IconButton(icon: const Icon(Icons.group), onPressed: () {}),
        ],
      ),
      body: FutureBuilder<List<Generation>>(
        future: _generationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final generations = snapshot.data!;
            return ListView.builder(
              itemCount: generations.length,
              itemBuilder: (context, index) {
                final generation = generations[index];
                return DisplayGenerationWidget(
                  generation: generation,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenerationScreen(generation: generation),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
