import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteMoviesProvider with ChangeNotifier {
  Set<int> _favoriteMovieIds = {};
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Set<int> get favoriteMovieIds => _favoriteMovieIds;

  FavoriteMoviesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .doc('movies')
              .get();

      if (doc.exists && doc.data() != null) {
        final List<dynamic> favoritesList = doc.data()!['movieIds'] ?? [];
        _favoriteMovieIds = Set<int>.from(favoritesList.map((x) => x as int));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc('movies')
          .set({
            'movieIds': _favoriteMovieIds.toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  bool isFavorite(int movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  Future<void> toggleFavorite(int movieId) async {
    if (_favoriteMovieIds.contains(movieId)) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    await _saveFavorites();
    notifyListeners();
  }

  // Listen to real-time updates
  void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc('movies')
        .snapshots()
        .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final List<dynamic> favoritesList = doc.data()!['movieIds'] ?? [];
            _favoriteMovieIds = Set<int>.from(
              favoritesList.map((x) => x as int),
            );
            notifyListeners();
          }
        });
  }
}
