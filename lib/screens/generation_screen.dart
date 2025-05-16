import 'package:flutter/material.dart';
import 'package:pokemon_pokedex_app/screens/favorites_screen.dart';
import 'package:pokemon_pokedex_app/widgets/team_overlay.dart';
import '../models/generation.dart';
import '../models/pokemon.dart';
import '../services/api_service.dart';
import '../widgets/display_pokemon_widget.dart';

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
  List<Pokemon> searchResults = [];
  int currentPage = 0;
  bool isLoading = false;
  bool allLoaded = false;
  bool isSearching = false;
  String searchQuery = '';

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchSpeciesList();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text;
      isSearching = searchQuery.isNotEmpty;
      searchResults.clear();
      if (isSearching && searchQuery.isNotEmpty) {
        _performSearch();
      }
    });
  }

  Future<void> _performSearch() async {
    try {
      final results = await ApiService.searchPokemon(searchQuery.toLowerCase());
      setState(() {
        searchResults = results;
        // Reset the scroll position when new results are loaded
        _scrollController.jumpTo(0);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching: $e')),
      );
    }
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
    print('Building with isSearching: $isSearching');
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Generation ${widget.generation.name}')
            : TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Pokémon...',
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        isSearching = false;
                        _searchController.clear();
                        searchResults.clear();
                        loadedPokemons.clear();
                        currentPage = 0;
                        fetchSpeciesList();
                      });
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                autofocus: true,
              ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isSearching = true;
                  _searchController.clear();
                });
              },
            ),
          if (isSearching)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  _searchController.clear();
                  searchResults.clear();
                  loadedPokemons.clear();
                  currentPage = 0;
                  fetchSpeciesList();
                });
              },
            ),
          IconButton(
          icon: const Icon(Icons.favorite), 
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FavoritesScreen(),
              ),
            );
          }),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const TeamOverlay(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: isSearching 
                  ? searchResults.length 
                  : loadedPokemons.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (isSearching) {
                  if (index < searchResults.length) {
                    return DisplayPokemonWidget(
                      pokemon: searchResults[index],
                      onFavoriteChanged: (pokemon) {
                        setState(() {
                          searchResults[index] = pokemon;
                        });
                      },
                    );
                  }
                } else {
                  if (index < loadedPokemons.length) {
                    return DisplayPokemonWidget(
                      pokemon: loadedPokemons[index],
                      onFavoriteChanged: (pokemon) {
                        setState(() {
                          loadedPokemons[index] = pokemon;
                        });
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          if (isLoading && !isSearching)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}