import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movieData;
  const MovieDetailPage({super.key, required this.movieData});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    print(widget.movieData['id']);
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backdrop and Back Button
            Stack(
              children: [
                widget.movieData['backdrop_path'] != null
                    ? Image.network(
                      'https://image.tmdb.org/t/p/original${widget.movieData['backdrop_path']}',
                      width: size.width,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      width: size.width,
                      height: 250,
                      color: Colors.grey[800],
                    ),
                Positioned(
                  top: 40,
                  left: 10,
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
                // Gradient overlay for better text visibility
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, const Color(0xFF181829)],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Release Year
                  Text(
                    '${widget.movieData['title']} (${DateTime.parse(widget.movieData['release_date']).year})',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Genres
                  Wrap(
                    spacing: 8,
                    children:
                        (widget.movieData['genres'] as List)
                            .map(
                              (genre) => Chip(
                                label: Text(
                                  genre['name'],
                                  style: const TextStyle(color: Colors.black),
                                ),
                                backgroundColor: Colors.white.withOpacity(0.1),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.movieData['vote_average'].toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '(${widget.movieData['vote_count']} votes)',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Overview
                  Text(
                    'Overview',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.movieData['overview'],
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 24),

                  // Trailers Section
                  if (widget.movieData['trailers'] != null &&
                      (widget.movieData['trailers'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trailers',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                (widget.movieData['trailers'] as List).length,
                            itemBuilder: (context, index) {
                              final trailer =
                                  widget.movieData['trailers'][index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    _launchURL(
                                      'https://www.youtube.com/watch?v=${trailer['key']}',
                                    );
                                  },
                                  icon: const Icon(Icons.play_circle_outline),
                                  label: Text('Trailer ${index + 1}'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Streaming Platforms Section
                  if (widget.movieData['streaming_providers'] != null &&
                      (widget.movieData['streaming_providers']['buy'] != null ||
                          widget.movieData['streaming_providers']['rent'] !=
                              null ||
                          widget.movieData['streaming_providers']['flatrate'] !=
                              null))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Watch Options',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 16),

                        // Flatrate (Streaming) Section
                        if (widget
                                .movieData['streaming_providers']['flatrate'] !=
                            null) ...[
                          Text(
                            'Stream',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (widget.movieData['streaming_providers']['flatrate']
                                        as List)
                                    .map(
                                      (provider) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (provider['logo_path'] != null)
                                              Image.network(
                                                'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                                                height: 20,
                                                width: 20,
                                              ),
                                            if (provider['logo_path'] != null)
                                              const SizedBox(width: 8),
                                            Text(
                                              provider['provider_name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Buy Section
                        if (widget.movieData['streaming_providers']['buy'] !=
                            null) ...[
                          Text(
                            'Buy',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (widget.movieData['streaming_providers']['buy']
                                        as List)
                                    .map(
                                      (provider) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (provider['logo_path'] != null)
                                              Image.network(
                                                'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                                                height: 20,
                                                width: 20,
                                              ),
                                            if (provider['logo_path'] != null)
                                              const SizedBox(width: 8),
                                            Text(
                                              provider['provider_name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Rent Section
                        if (widget.movieData['streaming_providers']['rent'] !=
                            null) ...[
                          Text(
                            'Rent',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                (widget.movieData['streaming_providers']['rent']
                                        as List)
                                    .map(
                                      (provider) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (provider['logo_path'] != null)
                                              Image.network(
                                                'https://image.tmdb.org/t/p/original${provider['logo_path']}',
                                                height: 20,
                                                width: 20,
                                              ),
                                            if (provider['logo_path'] != null)
                                              const SizedBox(width: 8),
                                            Text(
                                              provider['provider_name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Cast Section
                  const SizedBox(height: 24),
                  Text(
                    'Cast',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  if (widget.movieData['credits'] != null)
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            (widget.movieData['credits']['cast'] as List)
                                .length,
                        itemBuilder: (context, index) {
                          final cast =
                              widget.movieData['credits']['cast'][index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child:
                                      cast['profile_path'] != null
                                          ? Image.network(
                                            'https://image.tmdb.org/t/p/w185${cast['profile_path']}',
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    cast['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Crew Section
                  const SizedBox(height: 24),
                  Text(
                    'Crew',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  if (widget.movieData['credits'] != null)
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                            (widget.movieData['credits']['crew'] as List)
                                .length,
                        itemBuilder: (context, index) {
                          final crew =
                              widget.movieData['credits']['crew'][index];
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child:
                                      crew['profile_path'] != null
                                          ? Image.network(
                                            'https://image.tmdb.org/t/p/w185${crew['profile_path']}',
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            height: 80,
                                            width: 80,
                                            color: Colors.grey[800],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            ),
                                          ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          crew['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        crew['job'],
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Additional Information
                  const SizedBox(height: 24),
                  Text(
                    'Additional Information',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(
                    'Runtime',
                    '${widget.movieData['runtime']} minutes',
                  ),
                  _buildInfoRow(
                    'Language',
                    widget.movieData['original_language']
                        .toString()
                        .toUpperCase(),
                  ),
                  _buildInfoRow(
                    'Release Date',
                    widget.movieData['release_date'],
                  ),
                  _buildInfoRow('Status', widget.movieData['status']),

                  if (widget.movieData['production_countries'] != null &&
                      (widget.movieData['production_countries'] as List)
                          .isNotEmpty)
                    _buildInfoRow(
                      'Production Countries',
                      (widget.movieData['production_countries'] as List)
                          .map((country) => country['name'])
                          .join(', '),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
