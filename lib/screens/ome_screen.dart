import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_gator/screens/university_compare.dart';

import '/model/university_model.dart';
import '/screens/widgets/drawer.dart';
import '/widgets/university_card.dart';
import 'favourite/favourite_events_of_university.dart';
import 'favourite/favourite_universities.dart';

class UniversityListScreen extends StatefulWidget {
  const UniversityListScreen({super.key});

  @override
  State<UniversityListScreen> createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<University> universities = [];
  List<University> filteredUniversities = [];
  List<String> categories = [
    'Medical',
    'Computer Science',
    'Business',
    'Engineering',
    'Social Sciences',
    'Natural Sciences',
    'Arts',
    'Law'
  ];
  String searchQuery = '';
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadFavoriteCount();
    loadUniversities();
  }

  Future<void> loadUniversities() async {
    final String response =
        await rootBundle.loadString('assets/university_data.json');
    final data = await json.decode(response);
    setState(() {
      universities =
          List<University>.from(data.map((json) => University.fromJson(json)));
      filteredUniversities = universities;
    });
  }

  String normalizeProgram(String program) {
    program = program.toLowerCase();
    if (program.contains('computer') ||
        program.contains('software') ||
        program.contains('it') ||
        program.contains('artificial intelligence')) {
      return 'computer science';
    } else if (program.contains('business') ||
        program.contains('bba') ||
        program.contains('management')) {
      return 'business';
    } else if (program.contains('engineer')) {
      return 'engineering';
    } else if (program.contains('medic') ||
        program.contains('health') ||
        program.contains('pharma')) {
      return 'medical';
    } else if (program.contains('social') ||
        program.contains('econom') ||
        program.contains('psycholog')) {
      return 'social sciences';
    } else if (program.contains('physics') ||
        program.contains('chemistry') ||
        program.contains('biology') ||
        program.contains('math')) {
      return 'natural sciences';
    } else if (program.contains('art') ||
        program.contains('design') ||
        program.contains('music')) {
      return 'arts';
    } else if (program.contains('law') || program.contains('legal')) {
      return 'law';
    }
    return program;
  }

  void filterUniversities({String? query, String? category}) {
    setState(() {
      searchQuery = query ?? searchQuery;
      selectedCategory = category;

      filteredUniversities = universities.where((university) {
        bool matchesSearch =
            university.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                university.programs.any((program) =>
                    program.toLowerCase().contains(searchQuery.toLowerCase()));

        bool matchesCategory = selectedCategory == null ||
            university.programs.any((program) {
              String normalizedProgram = normalizeProgram(program);
              return normalizedProgram == selectedCategory!.toLowerCase();
            });

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  int favoriteCount = 0;

  Future<void> _loadFavoriteCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoriteIds = prefs.getStringList('favoriteIds') ?? [];
    setState(() {
      favoriteCount = favoriteIds.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(
              child: _buildUniversityList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: const Icon(Icons.menu, color: Colors.blue, size: 30),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const FavouriteEventsOfUniversityScreen(),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 30,
                    ),
                    if (favoriteCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 15,
                          ),
                          child: Text(
                            favoriteCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const FavouriteUniversityScreen(),
                    ),
                  );
                },
                child: const Icon(
                  Icons.favorite_outline,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const UniversityComparisonScreen(),
                      ));
                },
                child: const Icon(Icons.compare_arrows_rounded,
                    color: Colors.blue, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search by University\'s Name or Program',
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.blue.withOpacity(0.1),
        ),
        onChanged: (query) => filterUniversities(query: query),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFilterChip('All', null);
          }
          return _buildFilterChip(categories[index - 1], categories[index - 1]);
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: selectedCategory == category,
        onSelected: (bool selected) {
          filterUniversities(category: selected ? category : null);
        },
      ),
    );
  }

  Widget _buildUniversityList() {
    return ListView.builder(
      itemCount: filteredUniversities.length,
      itemBuilder: (context, index) {
        return UniversityCard(university: filteredUniversities[index]);
      },
    );
  }
}
