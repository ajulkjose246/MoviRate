import 'package:flutter/material.dart';
import 'package:movirate/screen/favorite_page.dart';
import 'package:movirate/screen/home_page.dart';
import 'package:movirate/screen/search_page.dart';
import 'package:movirate/services/api_services.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _selectedIndex = 0;

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.favorite_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = ['Home', 'Search', 'Favorites', 'Profile'];

  // Add your pages here
  final List<Widget> _pages = [
    HomePage(), // Replace with your actual page widgets
    SearchPage(),
    FavoritePage(),
    Text("data"),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  void fetchMovies() async {
    final movies = await ApiService().fetchPopularMovies();
    print(movies); // This will print the actual list of movies
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF181829),
      body: _pages[_selectedIndex], // Show the selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF232336),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: false,
        items: List.generate(_icons.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _labels[index],
          );
        }),
      ),
    );
  }
}
