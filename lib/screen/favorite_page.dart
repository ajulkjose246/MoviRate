import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_movies_provider.dart';
import '../services/api_services.dart';
import '../widgets/movie_card.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ApiService _apiService = ApiService();
  Map<int, Map<String, dynamic>> _movieDetails = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  Future<void> _loadMovieDetails() async {
    final favoriteMovies = Provider.of<FavoriteMoviesProvider>(
      context,
      listen: false,
    );
    setState(() => _isLoading = true);

    try {
      for (final movieId in favoriteMovies.favoriteMovieIds) {
        if (!_movieDetails.containsKey(movieId)) {
          final details = await _apiService.fetchMovieDetails(movieId);
          if (mounted) {
            setState(() {
              _movieDetails[movieId] = details;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading movie details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF181829),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF181829),

          body: Consumer<FavoriteMoviesProvider>(
            builder: (context, favoriteMovies, child) {
              if (_isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (favoriteMovies.favoriteMovieIds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite movies yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _loadMovieDetails,
                color: const Color(0xFF181829),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: favoriteMovies.favoriteMovieIds.length,
                    itemBuilder: (context, index) {
                      final movieId = favoriteMovies.favoriteMovieIds.elementAt(
                        index,
                      );
                      final movieData = _movieDetails[movieId];

                      if (movieData == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        );
                      }

                      return MovieCard(
                        imageUrl:
                            'https://image.tmdb.org/t/p/w500${movieData['poster_path']}',
                        title: movieData['title'],
                        rating: (movieData['vote_average'] as num).toDouble(),
                        movieId: movieId,
                        isFavorite: true,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
