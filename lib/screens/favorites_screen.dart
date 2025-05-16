import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokemon_pokedex_app/models/pokemon.dart';
import 'package:pokemon_pokedex_app/services/api_service.dart';
import 'package:pokemon_pokedex_app/services/local_storage_service.dart';
import 'package:pokemon_pokedex_app/widgets/app_bar_widget.dart';
import 'package:pokemon_pokedex_app/widgets/display_pokemon_widget.dart';

class FavoritesScreen extends StatefulWidget {

  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  
  static const int pageSize = 20;

  late List<int> favouriteList = [];
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
      favouriteList = await LocalStorageService.getFavoriteIdsList();
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
    final slice = favouriteList.length > start
        ? favouriteList.sublist(start, end > favouriteList.length ? favouriteList.length : end)
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
    for (var pokeId in slice) {
      final poke = await ApiService.fetchPokemonById(pokeId);
      if (poke != null) {
        newPokemons.add(poke);
      }
    }

    setState(() {
      loadedPokemons.addAll(newPokemons);
      currentPage++;
      isLoading = false;
      if (loadedPokemons.length >= favouriteList.length) {
        allLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: "Favourites", isFavButtonPresent: false,),
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