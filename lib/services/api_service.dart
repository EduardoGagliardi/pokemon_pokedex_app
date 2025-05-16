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
}
