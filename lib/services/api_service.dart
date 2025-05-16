import 'dart:convert';
import 'package:http/http.dart' as http;
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

      for (var result in results) {
        final detailResponse = await http.get(Uri.parse(result['url']));
        if (detailResponse.statusCode == 200) {
          final detailJson = jsonDecode(detailResponse.body);
          generations.add(Generation.fromJson(detailJson));
        }
      }

      return generations;
    } else {
      throw Exception('Failed to load generations');
    }
  }

  /// Fetch list of Pokémon species URLs for a given generation
  static Future<List<dynamic>> fetchPokemonSpeciesForGeneration(int generationId) async {
    final response = await http.get(Uri.parse('$baseUrl/generation/$generationId'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['pokemon_species'] as List<dynamic>;
    } else {
      throw Exception('Failed to load species for generation $generationId');
    }
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

  /// Search Pokémon by name (partial match)
  static Future<List<Pokemon>> searchPokemon(String searchTerm) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon?limit=1000'));
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> results = json['results'];
      
      // Filter results that contain the search term
      final filteredResults = results
          .where((pokemon) => 
              pokemon['name'].toString().contains(searchTerm.toLowerCase()))
          .map((pokemon) => 
            Future<Pokemon?>.sync(() async {
              final detailResponse = await http.get(Uri.parse(pokemon['url']));
              if (detailResponse.statusCode == 200) {
                final detailJson = jsonDecode(detailResponse.body);
                return Pokemon.fromJson(detailJson);
              }
              return null;
            })
          ).toList();
      
      // Wait for all Pokémon details to be fetched
      final pokemons = await Future.wait(filteredResults);
      return pokemons.where((p) => p != null).map((p) => p!).toList();
    } else {
      throw Exception('Failed to search Pokémon');
    }
  }
}
