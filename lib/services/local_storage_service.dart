import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String favoritesKey = 'favorites';
  static const String teamKey = 'team';

  static Future<Set<int>> getFavoriteIdsSet() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(favoritesKey) ?? [];
    return favList.map(int.parse).toSet();
  }

  static Future<List<int>> getFavoriteIdsList() async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList(favoritesKey) ?? [];
    return favList.map(int.parse).toList();
  }

  static Future<void> toggleFavorite(int pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    final favSet = await getFavoriteIdsSet();

    if (favSet.contains(pokemonId)) {
      favSet.remove(pokemonId);
    } else {
      favSet.add(pokemonId);
    }

    await prefs.setStringList(
      favoritesKey,
      favSet.map((id) => id.toString()).toList(),
    );
  }

  static Future<Set<int>> getTeamIds() async {
    final prefs = await SharedPreferences.getInstance();
    final teamList = prefs.getStringList(teamKey) ?? [];
    return teamList.map(int.parse).toSet();
  }

  static Future<bool> addToTeam(int pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    final teamSet = await getTeamIds();

    if (teamSet.length >= 6) return false;

    teamSet.add(pokemonId);
    await prefs.setStringList(
      teamKey,
      teamSet.map((id) => id.toString()).toList(),
    );
    return true;
  }

  static Future<void> removeFromTeam(int pokemonId) async {
    final prefs = await SharedPreferences.getInstance();
    final teamSet = await getTeamIds();
    teamSet.remove(pokemonId);
    await prefs.setStringList(
      teamKey,
      teamSet.map((id) => id.toString()).toList(),
    );
  }
}