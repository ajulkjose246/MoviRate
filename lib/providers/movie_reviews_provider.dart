import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieReview {
  final String id;
  final String movieId;
  final String userId;
  final String userName;
  final String review;
  final double rating;
  final DateTime createdAt;

  MovieReview({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userName,
    required this.review,
    required this.rating,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'userId': userId,
      'userName': userName,
      'review': review,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MovieReview.fromMap(String id, Map<String, dynamic> map) {
    return MovieReview(
      id: id,
      movieId: map['movieId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      review: map['review'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class MovieReviewsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MovieReview> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<MovieReview> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> addReview(String movieId, String review, double rating) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to add a review');
      }

      final newReview = MovieReview(
        id: '',
        movieId: movieId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        review: review,
        rating: rating,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('movie_reviews')
          .add(newReview.toMap());

      final addedReview = MovieReview(
        id: docRef.id,
        movieId: newReview.movieId,
        userId: newReview.userId,
        userName: newReview.userName,
        review: newReview.review,
        rating: newReview.rating,
        createdAt: newReview.createdAt,
      );

      _reviews.add(addedReview);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchReviewsForMovie(String movieId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final querySnapshot =
          await _firestore
              .collection('movie_reviews')
              .where('movieId', isEqualTo: movieId)
              .get();

      _reviews =
          querySnapshot.docs
              .map((doc) => MovieReview.fromMap(doc.id, doc.data()))
              .toList();

      // Sort reviews locally
      _reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to delete a review');
      }

      await _firestore.collection('movie_reviews').doc(reviewId).delete();
      _reviews.removeWhere((review) => review.id == reviewId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editReview(String reviewId, String review, double rating) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be logged in to edit a review');
      }

      final reviewIndex = _reviews.indexWhere((r) => r.id == reviewId);
      if (reviewIndex == -1) {
        throw Exception('Review not found');
      }

      final updatedReview = MovieReview(
        id: reviewId,
        movieId: _reviews[reviewIndex].movieId,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        review: review,
        rating: rating,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('movie_reviews')
          .doc(reviewId)
          .update(updatedReview.toMap());

      _reviews[reviewIndex] = updatedReview;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
