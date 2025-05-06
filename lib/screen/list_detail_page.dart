import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_lists_provider.dart';
import '../widgets/movie_card.dart';
import '../services/api_services.dart';

class ListDetailPage extends StatefulWidget {
  final MovieList movieList;

  const ListDetailPage({super.key, required this.movieList});

  @override
  State<ListDetailPage> createState() => _ListDetailPageState();
}

class _ListDetailPageState extends State<ListDetailPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;
  late String _currentListName;

  @override
  void initState() {
    super.initState();
    _currentListName = widget.movieList.name;
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> movies = [];
      for (final movieId in widget.movieList.movieIds) {
        final movieData = await _apiService.fetchMovieDetails(movieId);
        movies.add(movieData);
      }

      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading movies: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEditDialog() async {
    final TextEditingController controller = TextEditingController(
      text: widget.movieList.name,
    );
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF252534),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit List Name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter new name',
                    hintStyle: TextStyle(color: Colors.white54),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (controller.text.trim().isNotEmpty) {
                          Navigator.pop(context, controller.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF181829),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );

    if (result != null && result.isNotEmpty) {
      final provider = Provider.of<MovieListsProvider>(context, listen: false);
      await provider.editListName(widget.movieList.id, result);
      setState(() {
        _currentListName = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('List name updated')));
      }
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF252534),
            title: const Text(
              'Delete List',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${widget.movieList.name}"?',
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (result == true) {
      final provider = Provider.of<MovieListsProvider>(context, listen: false);
      await provider.deleteList(widget.movieList.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('List deleted')));
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
          appBar: AppBar(
            backgroundColor: const Color(0xFF181829),
            elevation: 0,
            title: Text(
              _currentListName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF252534),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditDialog();
                  } else if (value == 'delete') {
                    _showDeleteConfirmation();
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Edit Name',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Delete List',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : _movies.isEmpty
                  ? Center(
                    child: Text(
                      'No movies in this list yet',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
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
                    itemCount: _movies.length,
                    itemBuilder: (context, index) {
                      final movie = _movies[index];
                      return MovieCard(
                        imageUrl:
                            movie['poster_path'] != null
                                ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                : '',
                        title: movie['title'] ?? 'No Title',
                        rating: (movie['vote_average'] as num).toDouble(),
                        movieId: movie['id'] as int,
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
