import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'dart:math';
import 'package:provider/provider.dart';
import '../providers/watched_movies_provider.dart';
import '../providers/favorite_movies_provider.dart';
import '../providers/movie_lists_provider.dart';
import '../providers/movie_reviews_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movieData;
  const MovieDetailPage({super.key, required this.movieData});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  bool isInList = false;
  double userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Helper method to safely get string value
  String _getString(Map<String, dynamic> map, String key) {
    return map[key]?.toString() ?? '';
  }

  // Helper method to safely get double value
  double _getDouble(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is num) {
      return value.toDouble();
    }
    return 0.0;
  }

  // Helper method to safely get list
  List<Map<String, dynamic>> _getMapList(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is List) {
      return value.map((item) {
        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showReviewBottomSheet({bool isEditing = false, String? reviewId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: StatefulBuilder(
              builder:
                  (context, setState) => Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF181829),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      top: 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEditing ? 'Edit Review' : 'Write a Review',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Rating Stars Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Rating',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (userRating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  '${userRating.toInt()} / 5',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            5,
                            (index) => InkWell(
                              onTap: () {
                                setState(() {
                                  userRating = index + 1;
                                });
                                // Update parent state as well
                                this.setState(() {});
                              },
                              child: Icon(
                                index < userRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _reviewController,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Share your thoughts...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_reviewController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please write a review'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  if (userRating == 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please rate the movie'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    final reviewsProvider =
                                        Provider.of<MovieReviewsProvider>(
                                          context,
                                          listen: false,
                                        );

                                    if (isEditing && reviewId != null) {
                                      // TODO: Implement edit functionality in provider
                                      // await reviewsProvider.editReview(reviewId, _reviewController.text, userRating);
                                      await reviewsProvider.editReview(
                                        reviewId,
                                        _reviewController.text,
                                        userRating,
                                      );
                                    } else {
                                      await reviewsProvider.addReview(
                                        widget.movieData['id'].toString(),
                                        _reviewController.text,
                                        userRating,
                                      );
                                    }

                                    // Clear the form
                                    _reviewController.clear();
                                    setState(() {
                                      userRating = 0;
                                    });
                                    // Update parent state
                                    this.setState(() {});

                                    // Close the bottom sheet
                                    Navigator.pop(context);

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Review updated successfully!'
                                              : 'Review submitted successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error submitting review: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: Text(isEditing ? 'Update' : 'Submit'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
            ),
          ),
    );
  }

  void _showReviewDialog() {
    _showReviewBottomSheet(); // Redirect old method to new one for backward compatibility
  }

  void _showListsBottomSheet() {
    final TextEditingController newListController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF181829),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Consumer<MovieListsProvider>(
                builder: (context, listsProvider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add to List',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Create new list section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: newListController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Create new list...',
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.white),
                              onPressed: () {
                                if (newListController.text.isNotEmpty) {
                                  listsProvider.createList(
                                    newListController.text,
                                  );
                                  newListController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Existing lists
                      if (listsProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (listsProvider.lists.isEmpty)
                        const Center(
                          child: Text(
                            'No lists created yet',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: listsProvider.lists.length,
                            itemBuilder: (context, index) {
                              final list = listsProvider.lists[index];
                              final isInList = listsProvider.isMovieInList(
                                list.id,
                                widget.movieData['id'],
                              );

                              return ListTile(
                                title: Text(
                                  list.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Icon(
                                  isInList ? Icons.check : Icons.add,
                                  color: isInList ? Colors.green : Colors.white,
                                ),
                                onTap: () {
                                  if (isInList) {
                                    listsProvider.removeMovieFromList(
                                      list.id,
                                      widget.movieData['id'],
                                    );
                                  } else {
                                    listsProvider.addMovieToList(
                                      list.id,
                                      widget.movieData['id'],
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Lists are now automatically loaded in provider constructor
    // Load reviews after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final reviewsProvider = Provider.of<MovieReviewsProvider>(
      context,
      listen: false,
    );
    await reviewsProvider.fetchReviewsForMovie(
      widget.movieData['id'].toString(),
    );
  }

  Widget _buildReviewsList() {
    return Consumer<MovieReviewsProvider>(
      builder: (context, reviewsProvider, child) {
        if (reviewsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reviewsProvider.error != null) {
          return Center(
            child: Text(
              'Error loading reviews: ${reviewsProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (reviewsProvider.reviews.isEmpty) {
          return const Center(
            child: Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviewsProvider.reviews.length,
          itemBuilder: (context, index) {
            final review = reviewsProvider.reviews[index];
            final isUserReview = currentUser?.uid == review.userId;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUserReview)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  userRating = review.rating;
                                  _reviewController.text = review.review;
                                });
                                _showReviewBottomSheet(
                                  isEditing: true,
                                  reviewId: review.id,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        backgroundColor: const Color(
                                          0xFF181829,
                                        ),
                                        title: const Text(
                                          'Delete Review',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this review?',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  try {
                                    await reviewsProvider.deleteReview(
                                      review.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Review deleted successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error deleting review: ${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.review,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final watchedProvider = Provider.of<WatchedMoviesProvider>(context);
    final favoriteProvider = Provider.of<FavoriteMoviesProvider>(context);
    final isWatched = watchedProvider.isWatched(widget.movieData['id']);
    final isFavorite = favoriteProvider.isFavorite(widget.movieData['id']);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      body: Stack(
        children: [
          // Backdrop Image with Gradient
          SizedBox(
            height: size.height * 0.5,
            width: size.width,
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child:
                  widget.movieData['backdrop_path'] != null
                      ? Image.network(
                        'https://image.tmdb.org/t/p/original${widget.movieData['backdrop_path']}',
                        fit: BoxFit.cover,
                      )
                      : Container(color: Colors.grey[800]),
            ),
          ),

          // Main Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: size.height * 0.35),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF181829),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and Year
                            Text(
                              '${widget.movieData['title']} (${DateTime.parse(widget.movieData['release_date']).year})',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Rating and Duration Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.black,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.movieData['vote_average']
                                            .toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '${widget.movieData['runtime']} min',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white30),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.movieData['original_language']
                                        .toString()
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isWatched
                                              ? Colors.green
                                              : Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: () {
                                      watchedProvider.toggleWatched(
                                        widget.movieData['id'],
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          isWatched
                                              ? Icons.check
                                              : Icons.visibility,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          isWatched
                                              ? 'Watched'
                                              : 'Mark as Watched',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildCircularButton(
                                  icon:
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : Colors.white,
                                  onPressed: () {
                                    favoriteProvider.toggleFavorite(
                                      widget.movieData['id'],
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _buildCircularButton(
                                  icon:
                                      isInList
                                          ? Icons.playlist_add_check
                                          : Icons.playlist_add,
                                  color: isInList ? Colors.green : Colors.white,
                                  onPressed: _showListsBottomSheet,
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Genres
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    (widget.movieData['genres'] as List)
                                        .map(
                                          (genre) => Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              genre['name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Overview
                            const Text(
                              'Overview',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.movieData['overview'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // User Rating Section
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Rate this Movie',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (userRating > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                          child: Text(
                                            '${userRating.toInt()} / 5',
                                            style: const TextStyle(
                                              color: Colors.amber,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final starSize =
                                          (constraints.maxWidth - 20) / 5;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: List.generate(
                                          5,
                                          (index) => SizedBox(
                                            width: starSize,
                                            height: starSize,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: Icon(
                                                index < userRating
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: min(starSize * 0.8, 32.0),
                                              ),
                                              onPressed: () {
                                                setState(
                                                  () => userRating = index + 1,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                      onPressed: _showReviewBottomSheet,
                                      child: const Text(
                                        'Write a Review',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Cast and Crew sections
                            if (widget.movieData['credits'] != null) ...[
                              Builder(
                                builder: (context) {
                                  final credits = Map<String, dynamic>.from(
                                    widget.movieData['credits'] as Map,
                                  );
                                  final castList =
                                      (credits['cast'] as List?)
                                          ?.map(
                                            (item) => Map<String, dynamic>.from(
                                              item as Map,
                                            ),
                                          )
                                          .toList() ??
                                      [];
                                  final crewList =
                                      (credits['crew'] as List?)
                                          ?.map(
                                            (item) => Map<String, dynamic>.from(
                                              item as Map,
                                            ),
                                          )
                                          .toList() ??
                                      [];

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 24),
                                      _buildSectionTitle('Cast'),
                                      const SizedBox(height: 16),
                                      _buildCastList(castList),

                                      if (crewList.isNotEmpty) ...[
                                        const SizedBox(height: 24),
                                        _buildSectionTitle('Crew'),
                                        const SizedBox(height: 16),
                                        _buildCrewSection(crewList),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],

                            if (widget.movieData['trailers'] != null &&
                                (widget.movieData['trailers'] as List)
                                    .isNotEmpty) ...[
                              const SizedBox(height: 24),
                              _buildSectionTitle('Trailers'),
                              const SizedBox(height: 16),
                              _buildTrailersList(widget.movieData['trailers']),
                            ],

                            if (widget.movieData['streaming_providers'] !=
                                null) ...[
                              const SizedBox(height: 24),
                              _buildSectionTitle('Watch Options'),
                              const SizedBox(height: 16),
                              _buildStreamingSection(
                                widget.movieData['streaming_providers'],
                              ),
                            ],

                            // Reviews Section
                            const SizedBox(height: 24),
                            _buildSectionTitle('Reviews'),
                            const SizedBox(height: 16),
                            _buildReviewsList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(icon: Icon(icon), color: color, onPressed: onPressed),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCastList(List<Map<String, dynamic>> castData) {
    final List<Map<String, dynamic>> cast =
        castData.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cast.length,
        itemBuilder: (context, index) {
          final member = cast[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child:
                        _getString(member, 'profile_path').isNotEmpty
                            ? Image.network(
                              'https://image.tmdb.org/t/p/w185${_getString(member, 'profile_path')}',
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getString(member, 'name'),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrailersList(List trailers) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trailers.length,
        itemBuilder: (context, index) {
          final trailer = trailers[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                _launchURL('https://www.youtube.com/watch?v=${trailer['key']}');
              },
              icon: const Icon(Icons.play_circle_outline),
              label: Text('Trailer ${index + 1}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreamingSection(Map<String, dynamic> providers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (providers['flatrate'] != null) ...[
          _buildStreamingCategory('Stream', providers['flatrate']),
          const SizedBox(height: 16),
        ],
        if (providers['buy'] != null) ...[
          _buildStreamingCategory('Buy', providers['buy']),
          const SizedBox(height: 16),
        ],
        if (providers['rent'] != null)
          _buildStreamingCategory('Rent', providers['rent']),
      ],
    );
  }

  Widget _buildStreamingCategory(String title, List providers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              providers.map<Widget>((provider) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (provider['logo_path'] != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                            height: 24,
                            width: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        provider['provider_name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCrewSection(List<Map<String, dynamic>> crewData) {
    final List<Map<String, dynamic>> crew =
        crewData.map((item) {
          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }
          return <String, dynamic>{};
        }).toList();

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: crew.length,
        itemBuilder: (context, index) {
          final member = crew[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child:
                        _getString(member, 'profile_path').isNotEmpty
                            ? Image.network(
                              'https://image.tmdb.org/t/p/w185${_getString(member, 'profile_path')}',
                              fit: BoxFit.cover,
                            )
                            : Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getString(member, 'name'),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_getString(member, 'job')} (${_getString(member, 'department')})',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
