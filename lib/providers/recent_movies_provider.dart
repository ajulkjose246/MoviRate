import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RecentMoviesProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _recentMovies = [];
  static const String _recentMoviesKey = 'recent_movies';

  List<Map<String, dynamic>> get recentMovies => _recentMovies;

  Future<void> loadRecentMovies() async {
    final prefs = await SharedPreferences.getInstance();
    final recentMoviesJson = prefs.getStringList(_recentMoviesKey) ?? [];
    _recentMovies =
        recentMoviesJson
            .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
            .toList();
    notifyListeners();
  }

  Future<void> addRecentMovie(Map<String, dynamic> movieData) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentMoviesJson = prefs.getStringList(_recentMoviesKey) ?? [];

    // Convert movie to JSON string
    final movieJson = jsonEncode(movieData);

    // Remove the movie if it already exists
    recentMoviesJson.removeWhere((json) {
      final existingMovie = jsonDecode(json);
      return existingMovie['id'] == movieData['id'];
    });

    // Add the new movie at the beginning
    recentMoviesJson.insert(0, movieJson);

    // Keep only the latest 5 movies
    if (recentMoviesJson.length > 5) {
      recentMoviesJson = recentMoviesJson.sublist(0, 5);
    }

    await prefs.setStringList(_recentMoviesKey, recentMoviesJson);
    await loadRecentMovies(); // This will update the list and notify listeners
  }
}
