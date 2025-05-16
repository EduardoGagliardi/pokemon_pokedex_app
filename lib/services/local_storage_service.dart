import 'package:flutter/foundation.dart';
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

  static Future<void> toggleFavorite(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getFavoriteIdsSet();

      if (current.contains(id)) {
        current.remove(id);
      } else {
        current.add(id);
      }

      await prefs.setStringList(
        favoritesKey,
        current.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('⚠️ Error saving favorite: $e');
    }
  }

  static Future<Set<int>> getTeamIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final teamList = prefs.getStringList(teamKey) ?? [];

      if (teamList.isEmpty) {
        debugPrint('ℹ️ Team list is empty');
      }

      return teamList.map((s) => int.tryParse(s)).whereType<int>().toSet();
    } catch (e) {
      debugPrint('⚠️ Error loading team: $e');
      return {};
    }
  }

  static Future<bool> addToTeam(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getTeamIds();

      if (current.length >= 6) return false;
      current.add(id);

      await prefs.setStringList(
        teamKey,
        current.map((id) => id.toString()).toList(),
      );
      return true;
    } catch (e) {
      debugPrint('⚠️ Error adding to team: $e');
      return false;
    }
  }

  static Future<void> removeFromTeam(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = await getTeamIds();
      current.remove(id);
      await prefs.setStringList(
        teamKey,
        current.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('⚠️ Error removing from team: $e');
    }
  }
}