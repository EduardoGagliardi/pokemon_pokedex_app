import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pokemon_pokedex_app/models/flavor_texts.dart';
import '../models/generation.dart';
import '../models/pokemon.dart';

class ApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  /// Fetch all generations with details
  static Future<List<Generation>> fetchGenerations() async {
    final response = await http.get(Uri.parse('$baseUrl/generation/'));

    if (response.statusCode == 200) {
      final List<dynamic> results = jsonDecode(response.body)['results'];
      final List<Generation> generations = [];

      Iterable<Future<http.Response>> stagedFurtures = results.map((result) => 
        http.get(Uri.parse(result['url']))
      );
      final detailResponses = await Future.wait(stagedFurtures);

      for (final detailResponse in detailResponses) {
        if (detailResponse.statusCode == 200) {
          final detailJson = jsonDecode(detailResponse.body);
          generations.add(Generation.fromJson(detailJson));
        }
      }

      return generations;
    }

    throw Exception('Failed to load generations');
  }

  /// Fetch list of Pokémon species URLs for a given generation
  static Future<List<dynamic>> fetchPokemonSpeciesForGeneration(int generationId) async {
    final response = await http.get(Uri.parse('$baseUrl/generation/$generationId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['pokemon_species'] as List<dynamic>;
    }

    throw Exception('Failed to load species for generation $generationId');
  }

  /// Fetch Pokemon Species falvor text.
  static Future<FlavorTexts> fetchPokemonFlavorTextsByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon-species/$name'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return FlavorTexts.fromJson(json);
    }

    throw Exception('Failed to load species for flavor texts $name');
  }

  /// Fetch Pokémon details by its URL
  static Future<Pokemon?> fetchPokemonByUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Pokemon.fromJson(json);
    }
    return null;
  }

  /// Fetch Pokémon details by its Id
  static Future<Pokemon?> fetchPokemonById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/pokemon/$id"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Pokemon.fromJson(json);
    }
    return null;
  }

  /// Fetch Pokémon details by its Name
  static Future<Pokemon?> fetchPokemonByName(String name) async {
    final response = await http.get(Uri.parse("$baseUrl/pokemon/$name"));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return Pokemon.fromJson(json);
    }
    return null;
  }

  /// Search Pokémon by name (partial match)
  static Future<List<Pokemon>> searchPokemon(int generationId, String searchTerm) async {
    final response = await http.get(Uri.parse('$baseUrl/generation/$generationId'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> results = json['pokemon_species'];
      
      // Filter results that contain the search term
      final filteredResults = results
        .where((pokemon) {
          final name = pokemon["name"]?.toString().toLowerCase();
          return name != null && name.contains(searchTerm.toLowerCase());
        }).toList();

      List<Future<Pokemon?>> stagedFutures = filteredResults.map((poke) =>
        fetchPokemonByName(poke["name"].toString().toLowerCase())
      ).toList();

      List<Pokemon?> pokeList = await Future.wait(stagedFutures);
      return pokeList.whereType<Pokemon>().toList();
    }
    throw Exception('Failed to load queried pokemons');
  }
}