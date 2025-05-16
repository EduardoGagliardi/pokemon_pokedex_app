import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/local_storage_service.dart';
import '../services/api_service.dart';

class TeamOverlay extends StatefulWidget {
  const TeamOverlay({super.key});

  @override
  State<TeamOverlay> createState() => _TeamOverlayState();
}

class _TeamOverlayState extends State<TeamOverlay> {
  List<Pokemon> teamPokemons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  Future<void> _loadTeam() async {
    setState(() => isLoading = true);
    final teamIds = await LocalStorageService.getTeamIds();
    final List<Pokemon> pokemons = [];

    for (int id in teamIds) {
      final url = '${ApiService.baseUrl}/pokemon/$id';
      final poke = await ApiService.fetchPokemonByUrl(url);
      if (poke != null) pokemons.add(poke);
    }

    setState(() {
      teamPokemons = pokemons;
      isLoading = false;
    });
  }

  Future<void> _removeFromTeam(int id) async {
    await LocalStorageService.removeFromTeam(id);
    _loadTeam(); // refresh
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'My Pokémon Team',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : teamPokemons.isEmpty
                        ? const Center(child: Text('No Pokémon in team.'))
                        : ListView.builder(
                            controller: controller,
                            itemCount: teamPokemons.length,
                            itemBuilder: (context, index) {
                              final poke = teamPokemons[index];
                              return Card(
                                child: ListTile(
                                  leading: Image.network(poke.imageUrl),
                                  title: Text(
                                    poke.name[0].toUpperCase() + poke.name.substring(1),
                                  ),
                                  subtitle: Text('Types: ${poke.types.join(', ')}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                                    onPressed: () => _removeFromTeam(poke.id),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}