import 'package:flutter/material.dart';
import 'package:pokemon_pokedex_app/models/pokemon.dart';
import 'package:pokemon_pokedex_app/services/api_service.dart';
import 'package:pokemon_pokedex_app/services/local_storage_service.dart';
import 'package:pokemon_pokedex_app/widgets/app_bar_widget.dart';
import 'dart:math';

class PokemonScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonScreen({super.key, required this.pokemon});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  String? flavorText;
  bool isLoading = true;

  bool isFavorite = false;
  bool inTeam = false;

  @override
  void initState() {
    super.initState();
    _loadFlavorText();
  }

  Future<void> _loadFlavorText() async {
    final flavorTexts = await ApiService.fetchPokemonFlavorTextsByName(widget.pokemon.name);
    int randomIndex = Random().nextInt(flavorTexts.descriptions.length);
    setState(() {
      flavorText = flavorTexts.descriptions[randomIndex];
      isLoading = false;
    });
  }

  Future<void> _loadStatus() async {
    final favSet = await LocalStorageService.getFavoriteIdsSet();
    final teamSet = await LocalStorageService.getTeamIds();
    setState(() {
      isFavorite = favSet.contains(widget.pokemon.id);
      inTeam = teamSet.contains(widget.pokemon.id);
    });
  }

  void _toggleFavorite() async {
    await LocalStorageService.toggleFavorite(widget.pokemon.id);
    _loadStatus();
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
    return Scaffold(
      appBar: AppBarWidget(title: "Pokemon : ${widget.pokemon.name}"),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Picture
            Center(
              child: Image.network(
                widget.pokemon.imageUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),

            // Title
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  widget.pokemon.name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
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
            
            SizedBox(height: 12),

            // Column of Tags
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.pokemon.types.map((type) => Chip(label: Text(type))).toList(),
            ),
            SizedBox(height: 16),

            // Description
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Text(
                    flavorText ?? 'No description available.',
                    style: TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}