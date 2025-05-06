import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WatchedMoviesProvider with ChangeNotifier {
  Set<int> _watchedMovieIds = {};
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Set<int> get watchedMovieIds => _watchedMovieIds;

  WatchedMoviesProvider() {
    _loadWatchedMovies();
  }

  Future<void> _loadWatchedMovies() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('watched')
              .doc('movies')
              .get();

      if (doc.exists && doc.data() != null) {
        final List<dynamic> watchedList = doc.data()!['movieIds'] ?? [];
        _watchedMovieIds = Set<int>.from(watchedList.map((x) => x as int));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading watched movies: $e');
    }
  }

  Future<void> _saveWatchedMovies() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('watched')
          .doc('movies')
          .set({
            'movieIds': _watchedMovieIds.toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      print('Error saving watched movies: $e');
    }
  }

  bool isWatched(int movieId) {
    return _watchedMovieIds.contains(movieId);
  }

  Future<void> toggleWatched(int movieId) async {
    if (_watchedMovieIds.contains(movieId)) {
      _watchedMovieIds.remove(movieId);
    } else {
      _watchedMovieIds.add(movieId);
    }
    await _saveWatchedMovies();
    notifyListeners();
  }

  // Listen to real-time updates
  void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watched')
        .doc('movies')
        .snapshots()
        .listen((doc) {
          if (doc.exists && doc.data() != null) {
            final List<dynamic> watchedList = doc.data()!['movieIds'] ?? [];
            _watchedMovieIds = Set<int>.from(watchedList.map((x) => x as int));
            notifyListeners();
          }
        });
  }
}
