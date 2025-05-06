import 'package:flutter/material.dart';
import 'package:movirate/services/api_services.dart';
import 'package:movirate/widgets/movie_card.dart';
import 'package:provider/provider.dart';
import '../providers/recent_movies_provider.dart';
import '../screen/movie_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load recent movies when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecentMoviesProvider>().loadRecentMovies();
    });
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _apiService.searchMovies(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching movies: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF232336),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) => _searchMovies(value),
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.white70,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchMovies('');
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Rebuild to show/hide clear button
                      if (value.length >= 2) {
                        _searchMovies(value);
                      } else if (value.isEmpty) {
                        _searchMovies('');
                      }
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh:
                    () =>
                        context.read<RecentMoviesProvider>().loadRecentMovies(),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _searchResults.isEmpty
                        ? Consumer<RecentMoviesProvider>(
                          builder: (context, recentMoviesProvider, child) {
                            final recentMovies =
                                recentMoviesProvider.recentMovies;
                            return Column(
                              children: [
                                if (_searchController.text.isEmpty &&
                                    recentMovies.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Recently Viewed Movies',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            childAspectRatio: 0.7,
                                            crossAxisSpacing: 16,
                                            mainAxisSpacing: 16,
                                          ),
                                      itemCount: recentMovies.length,
                                      itemBuilder: (context, index) {
                                        final movie = recentMovies[index];
                                        return MovieCard(
                                          imageUrl: movie['poster_path'],
                                          title: movie['title'],
                                          rating:
                                              (movie['vote_average'] as num)
                                                  .toDouble(),
                                          movieId: movie['id'],
                                        );
                                      },
                                    ),
                                  ),
                                ] else
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        _searchController.text.isEmpty
                                            ? 'Search for movies'
                                            : 'No movies found',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        )
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            final rating = movie['vote_average'] ?? 0.0;
                            final movieID = movie['id'];
                            final imageUrl =
                                movie['poster_path'] != null
                                    ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                    : '';
                            final title = movie['title'] ?? 'No Title';

                            return MovieCard(
                              imageUrl: imageUrl,
                              title: title,
                              rating: rating.toDouble(),
                              movieId: movieID,
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
