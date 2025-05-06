import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiKey = '5799d45108c37f0ab5e55a7ebc87029c';
  static const String _baseUrl = 'https://api.themoviedb.org/3/movie';
  static const String _searchUrl = 'https://api.themoviedb.org/3/search/movie';

  Future<List<dynamic>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/popular?api_key=$_apiKey&page=1'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<dynamic>> fetchTopRatedMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/top_rated?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<List<dynamic>> fetchNowPlayingMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/now_playing?api_key=$_apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to load top rated movies');
    }
  }

  Future<List<dynamic>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final response = await http.get(
      Uri.parse(
        '$_searchUrl?api_key=$_apiKey&query=${Uri.encodeComponent(query)}',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final movieResponse = await http.get(
      Uri.parse('$_baseUrl/$movieId?api_key=$_apiKey'),
    );
    final creditsResponse = await http.get(
      Uri.parse('$_baseUrl/$movieId/credits?api_key=$_apiKey'),
    );
    final videosResponse = await http.get(
      Uri.parse('$_baseUrl/$movieId/videos?api_key=$_apiKey&language=en-US'),
    );
    final providersResponse = await http.get(
      Uri.parse('$_baseUrl/$movieId/watch/providers?api_key=$_apiKey'),
    );

    if (movieResponse.statusCode == 200 &&
        creditsResponse.statusCode == 200 &&
        videosResponse.statusCode == 200 &&
        providersResponse.statusCode == 200) {
      final movieData = json.decode(movieResponse.body) as Map<String, dynamic>;
      final creditsData =
          json.decode(creditsResponse.body) as Map<String, dynamic>;
      final videosData =
          json.decode(videosResponse.body) as Map<String, dynamic>;
      final providersData =
          json.decode(providersResponse.body) as Map<String, dynamic>;

      // Get only first 10 cast members
      final List<Map<String, dynamic>> limitedCast =
          ((creditsData['cast'] as List?) ?? [])
              .take(10)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      // Get only first 10 crew members
      final List<Map<String, dynamic>> limitedCrew =
          ((creditsData['crew'] as List?) ?? [])
              .take(10)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      // Filter only trailer type videos
      final List<Map<String, dynamic>> trailers =
          ((videosData['results'] as List?) ?? [])
              .where((video) => (video as Map)['type'] == 'Trailer')
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();

      // Get Indian streaming providers if available
      final results = providersData['results'] as Map<String, dynamic>?;
      final indianProviders =
          results != null && results.containsKey('IN')
              ? Map<String, dynamic>.from(results['IN'] as Map)
              : <String, dynamic>{};

      return {
        ...movieData,
        'credits': {'cast': limitedCast, 'crew': limitedCrew},
        'trailers': trailers,
        'streaming_providers': indianProviders,
      };
    } else {
      throw Exception(
        'Failed to load movie details, credits, trailers or providers',
      );
    }
  }
}
