import 'package:flutter/material.dart';
import '../models/generation.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import '../widgets/display_pokemon_widget.dart';
import '../widgets/team_overlay.dart';

class GenerationScreen extends StatefulWidget {
  final Generation generation;

  const GenerationScreen({super.key, required this.generation});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  static const int pageSize = 20;

  late List<dynamic> speciesList = [];
  List<Pokemon> loadedPokemons = [];
  int currentPage = 0;
  bool isLoading = false;
  bool allLoaded = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSpeciesList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoading &&
        !allLoaded) {
      loadMorePokemons();
    }
  }

  Future<void> fetchSpeciesList() async {
    setState(() {
      isLoading = true;
    });

    try {
      speciesList = await ApiService.fetchPokemonSpeciesForGeneration(widget.generation.id);
      await loadMorePokemons();
    } catch (e) {
      // handle error
      print('Error fetching species list: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMorePokemons() async {
    if (allLoaded) return;

    setState(() {
      isLoading = true;
    });

    final start = currentPage * pageSize;
    final end = start + pageSize;
    final slice = speciesList.length > start
        ? speciesList.sublist(start, end > speciesList.length ? speciesList.length : end)
        : [];

    if (slice.isEmpty) {
      setState(() {
        allLoaded = true;
        isLoading = false;
      });
      return;
    }

    // Fetch Pokemon details for this page
    List<Pokemon> newPokemons = [];
    for (var species in slice) {
      final detailUrl = species['url']
          .replaceFirst('/pokemon-species/', '/pokemon/');
      final poke = await ApiService.fetchPokemonByUrl(detailUrl);
      if (poke != null) {
        newPokemons.add(poke);
      }
    }

    setState(() {
      loadedPokemons.addAll(newPokemons);
      currentPage++;
      isLoading = false;
      if (loadedPokemons.length >= speciesList.length) {
        allLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Génération ${widget.generation.id} - ${widget.generation.region}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              // TODO: Navigate to favorites screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                ), 
                builder: (_) => const TeamOverlay(),
              );
            }
            )
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: loadedPokemons.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < loadedPokemons.length) {
            return DisplayPokemonWidget(pokemon: loadedPokemons[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}