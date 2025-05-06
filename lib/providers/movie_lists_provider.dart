import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieList {
  final String id;
  final String name;
  final List<int> movieIds;

  MovieList({required this.id, required this.name, required this.movieIds});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'movieIds': movieIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory MovieList.fromMap(String id, Map<String, dynamic> map) {
    return MovieList(
      id: id,
      name: map['name'] as String,
      movieIds: List<int>.from(map['movieIds'] as List),
    );
  }
}

class MovieListsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<MovieList> _lists = [];
  bool _isLoading = false;

  List<MovieList> get lists => _lists;
  bool get isLoading => _isLoading;

  MovieListsProvider() {
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      _isLoading = true;
      notifyListeners();

      final snapshot =
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('movie_lists')
              .get();

      _lists =
          snapshot.docs
              .map((doc) => MovieList.fromMap(doc.id, doc.data()))
              .toList();
    } catch (e) {
      print('Error loading lists: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createList(String name) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_lists')
          .add({
            'name': name,
            'movieIds': [],
            'updatedAt': FieldValue.serverTimestamp(),
          });

      _lists.add(MovieList(id: docRef.id, name: name, movieIds: []));
      notifyListeners();
    } catch (e) {
      print('Error creating list: $e');
    }
  }

  Future<void> addMovieToList(String listId, int movieId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final index = _lists.indexWhere((list) => list.id == listId);
      if (index == -1) return;

      if (!_lists[index].movieIds.contains(movieId)) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('movie_lists')
            .doc(listId)
            .update({
              'movieIds': FieldValue.arrayUnion([movieId]),
              'updatedAt': FieldValue.serverTimestamp(),
            });

        _lists[index].movieIds.add(movieId);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding movie to list: $e');
    }
  }

  Future<void> removeMovieFromList(String listId, int movieId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final index = _lists.indexWhere((list) => list.id == listId);
      if (index == -1) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_lists')
          .doc(listId)
          .update({
            'movieIds': FieldValue.arrayRemove([movieId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      _lists[index].movieIds.remove(movieId);
      notifyListeners();
    } catch (e) {
      print('Error removing movie from list: $e');
    }
  }

  Future<void> editListName(String listId, String newName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final index = _lists.indexWhere((list) => list.id == listId);
      if (index == -1) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_lists')
          .doc(listId)
          .update({'name': newName, 'updatedAt': FieldValue.serverTimestamp()});

      _lists[index] = MovieList(
        id: _lists[index].id,
        name: newName,
        movieIds: _lists[index].movieIds,
      );
      notifyListeners();
    } catch (e) {
      print('Error editing list name: $e');
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('movie_lists')
          .doc(listId)
          .delete();

      _lists.removeWhere((list) => list.id == listId);
      notifyListeners();
    } catch (e) {
      print('Error deleting list: $e');
    }
  }

  bool isMovieInList(String listId, int movieId) {
    final list = _lists.firstWhere(
      (list) => list.id == listId,
      orElse: () => MovieList(id: '', name: '', movieIds: []),
    );
    return list.movieIds.contains(movieId);
  }

  // Listen to real-time updates
  void startListening() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('movie_lists')
        .snapshots()
        .listen((snapshot) {
          _lists =
              snapshot.docs
                  .map((doc) => MovieList.fromMap(doc.id, doc.data()))
                  .toList();
          notifyListeners();
        });
  }
}
