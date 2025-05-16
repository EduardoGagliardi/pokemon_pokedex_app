import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../services/local_storage_service.dart';

class DisplayPokemonWidget extends StatefulWidget {
  final Pokemon pokemon;
  final Function(Pokemon)? onFavoriteChanged;

  const DisplayPokemonWidget({
    super.key,
    required this.pokemon,
    this.onFavoriteChanged,
  });

  @override
  _DisplayPokemonWidgetState createState() => _DisplayPokemonWidgetState();
}

class _DisplayPokemonWidgetState extends State<DisplayPokemonWidget> {
  bool isFavorite = false;
  bool inTeam = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final favSet = await LocalStorageService.getFavoriteIds();
    final teamSet = await LocalStorageService.getTeamIds();
    setState(() {
      isFavorite = favSet.contains(widget.pokemon.id);
      inTeam = teamSet.contains(widget.pokemon.id);
    });
  }

  void _toggleFavorite() async {
    await LocalStorageService.toggleFavorite(widget.pokemon.id);
    _loadStatus();
    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!(widget.pokemon);
    }
  }

  void _toggleTeam() async {
    if (inTeam) {
      await LocalStorageService.removeFromTeam(widget.pokemon.id);
    } else {
      final success = await LocalStorageService.addToTeam(widget.pokemon.id);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team is full (max 6 Pokémon)')),
        );
      }
    }
    _loadStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: widget.pokemon.imageUrl.isNotEmpty
            ? Image.network(widget.pokemon.imageUrl)
            : const FlutterLogo(),
        title: Text(
          widget.pokemon.name[0].toUpperCase() + widget.pokemon.name.substring(1),
        ),
        subtitle: Text('Types: ${widget.pokemon.types.join(', ')}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red),
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: Icon(inTeam ? Icons.group : Icons.group_outlined,
                  color: Colors.blue),
              onPressed: _toggleTeam,
            ),
          ],
        ),
        onTap: () {
          // TODO: Show Pokemon detail overlay
        },
      ),
    );
  }
}
