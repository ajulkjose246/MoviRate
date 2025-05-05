import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../widgets/movie_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF181829),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFF181829),
          appBar: AppBar(
            backgroundColor: const Color(0xFF181829),
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Text(
              'Movirate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Popular Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: FutureBuilder<List<dynamic>>(
                    future: _apiService.fetchPopularMovies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: \\${snapshot.error}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No movies found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final movieID = movie['id'];
                          final rating = movie['vote_average'];
                          final imageUrl =
                              movie['poster_path'] != null
                                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                  : '';
                          final title = movie['title'] ?? 'No Title';
                          return MovieCard(
                            imageUrl: imageUrl,
                            title: title,
                            rating: rating,
                            movieId: movieID,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Top Rated Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: FutureBuilder<List<dynamic>>(
                    future: _apiService.fetchTopRatedMovies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: \\${snapshot.error}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No movies found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final movieID = movie['id'];
                          final rating = movie['vote_average'];
                          final imageUrl =
                              movie['poster_path'] != null
                                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                  : '';
                          final title = movie['title'] ?? 'No Title';
                          return MovieCard(
                            imageUrl: imageUrl,
                            title: title,
                            rating: rating,
                            movieId: movieID,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Now Playing Movies',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: FutureBuilder<List<dynamic>>(
                    future: _apiService.fetchNowPlayingMovies(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: \\${snapshot.error}',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            'No movies found',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      final movies = snapshot.data!;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          final movieID = movie['id'];
                          final rating = movie['vote_average'];
                          final imageUrl =
                              movie['poster_path'] != null
                                  ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                  : '';
                          final title = movie['title'] ?? 'No Title';
                          return MovieCard(
                            imageUrl: imageUrl,
                            title: title,
                            rating: rating,
                            movieId: movieID,
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
