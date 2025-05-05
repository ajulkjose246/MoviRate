import 'package:flutter/material.dart';

class MovieDetailPage extends StatefulWidget {
  final Map<String, dynamic> movieData;
  const MovieDetailPage({super.key, required this.movieData});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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

                  // Additional Information

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
                  const SizedBox(height: 16),
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
