// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:uni_gator/widgets/custom_button.dart';
// import 'package:uni_gator/widgets/university_card.dart';

// import '/model/university_model.dart';

// class UniversityRecommendation extends StatefulWidget {
//   const UniversityRecommendation({super.key});

//   @override
//   _UniversityRecommendationState createState() =>
//       _UniversityRecommendationState();
// }

// class _UniversityRecommendationState extends State<UniversityRecommendation> {
//   List<University> universities = [];
//   List<University> filteredUniversities = [];
//   String? selectedCity;
//   String? selectedProgram;
//   String? selectedFees;
//   String? selectedSSC;
//   String? selectedHSC;
//   bool isLoading = false;

//   final List<String> cityOptions = [
//     'Karachi',
//     'Lahore',
//     'Islamabad',
//     'Faisalabad',
//     'Jamshoro',
//     'Khairpur',
//   ];
//   final List<String> programOptions = [
//     'MBBS',
//     'BBA',
//     'BS Computer Science',
//     'BS Engineering'
//   ];
//   final List<String> feeRangeOptions = [
//     '50,000 - 100,000',
//     '100,000 - 200,000',
//     '350,000 - 1,000,000'
//   ];
//   final List<String> percentageOptions = ['50%', '60%', '70%', '80%'];

//   @override
//   void initState() {
//     super.initState();
//     loadJsonData();
//   }

//   Future<void> loadJsonData() async {
//     try {
//       final String response =
//           await rootBundle.loadString('assets/university_data.json');
//       final data = await json.decode(response);
//       setState(() {
//         universities =
//             (data as List).map((item) => University.fromJson(item)).toList();
//       });
//     } catch (e) {
//       log('Error loading university data: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load university data')),
//       );
//     }
//   }

//   // Add this new method
//   bool _exceedsPercentageCriteria(
//       String? universityPercentage, String selectedPercentage) {
//     if (universityPercentage == null) return false;
//     try {
//       return int.parse(universityPercentage.replaceAll('%', '')) >
//           int.parse(selectedPercentage.replaceAll('%', ''));
//     } catch (e) {
//       log('Error parsing percentage: $e');
//       return false;
//     }
//   }

//   void _showRecommendationDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return StatefulBuilder(
//             builder: (BuildContext context, StateSetter setDialogState) {
//           return AlertDialog(
//             title: Text('Recommend a University'),
//             content: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildDropdown('City', selectedCity, cityOptions, (newValue) {
//                     setDialogState(() => selectedCity = newValue);
//                   }),
//                   _buildDropdown('Program', selectedProgram, programOptions,
//                       (newValue) {
//                     setDialogState(() => selectedProgram = newValue);
//                   }),
//                   _buildDropdown('Fee Range', selectedFees, feeRangeOptions,
//                       (newValue) {
//                     setDialogState(() => selectedFees = newValue);
//                   }),
//                   _buildDropdown(
//                       'SSC Percentage', selectedSSC, percentageOptions,
//                       (newValue) {
//                     setDialogState(() => selectedSSC = newValue);
//                   }),
//                   _buildDropdown(
//                       'HSC Percentage', selectedHSC, percentageOptions,
//                       (newValue) {
//                     setDialogState(() => selectedHSC = newValue);
//                   }),
//                 ],
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('Reset'),
//                 onPressed: () {
//                   setDialogState(() {
//                     selectedCity = null;
//                     selectedProgram = null;
//                     selectedFees = null;
//                     selectedSSC = null;
//                     selectedHSC = null;
//                   });
//                 },
//               ),
//               TextButton(
//                 child: Text('Submit'),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   setState(() {
//                     // Update the main widget's state
//                     selectedCity = selectedCity;
//                     selectedProgram = selectedProgram;
//                     selectedFees = selectedFees;
//                     selectedSSC = selectedSSC;
//                     selectedHSC = selectedHSC;
//                   });
//                   _getRecommendations();
//                 },
//               ),
//             ],
//           );
//         });
//       },
//     );
//   }

//   Widget _buildDropdown(String label, String? selectedValue, List<String> items,
//       Function(String?) onChanged) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(labelText: label),
//       value: selectedValue,
//       onChanged: onChanged,
//       items: items.map<DropdownMenuItem<String>>((String value) {
//         return DropdownMenuItem<String>(
//           value: value,
//           child: Text(value),
//         );
//       }).toList(),
//     );
//   }

//   void _getRecommendations() {
//     setState(() {
//       isLoading = true;
//     });

//     // Simulate API call
//     Future.delayed(const Duration(seconds: 2), () {
//       try {
//         List<University> cityMatches = [];
//         List<University> otherMatches = [];

//         // Step 1: Filter universities based on all user requirements
//         for (var university in universities) {
//           bool matches = (selectedProgram == null ||
//                   university.programs.contains(selectedProgram)) &&
//               (selectedFees == null ||
//                   _isInFeeRange(university.feeStructure, selectedFees!)) &&
//               (selectedSSC == null ||
//                   _meetsPercentageCriteria(
//                       university.minimumSSC, selectedSSC!)) &&
//               (selectedHSC == null ||
//                   _meetsPercentageCriteria(
//                       university.minimumHSC, selectedHSC!));

//           if (matches) {
//             if (selectedCity == null ||
//                 university.campuses.contains(selectedCity)) {
//               cityMatches.add(university);
//             } else {
//               otherMatches.add(university);
//             }
//           }
//         }

//         // Step 2: Score universities
//         void scoreUniversities(List<University> unis) {
//           for (var university in unis) {
//             int score = 0;
//             if (selectedCity != null &&
//                 university.campuses.contains(selectedCity)) score += 50;
//             if (selectedProgram != null &&
//                 university.programs.contains(selectedProgram)) score += 30;
//             if (selectedFees != null &&
//                 _isInFeeRange(university.feeStructure, selectedFees!))
//               score += 20;
//             if (selectedSSC != null &&
//                 _exceedsPercentageCriteria(university.minimumSSC, selectedSSC!))
//               score += 10;
//             if (selectedHSC != null &&
//                 _exceedsPercentageCriteria(university.minimumHSC, selectedHSC!))
//               score += 10;
//             university.score = score;
//           }
//         }

//         scoreUniversities(cityMatches);
//         scoreUniversities(otherMatches);

//         // Step 3: Sort universities by score (descending)
//         cityMatches.sort((a, b) => b.score.compareTo(a.score));
//         otherMatches.sort((a, b) => b.score.compareTo(a.score));

//         // Step 4: Combine results to get exactly 3 universities
//         filteredUniversities = cityMatches.take(3).toList();
//         if (filteredUniversities.length < 3) {
//           filteredUniversities
//               .addAll(otherMatches.take(3 - filteredUniversities.length));
//         }

//         // If we still don't have 3 universities, add any remaining universities
//         if (filteredUniversities.length < 3) {
//           var remainingUniversities = universities
//               .where((university) => !filteredUniversities.contains(university))
//               .toList();
//           remainingUniversities.sort((a, b) => b.rank.compareTo(
//               a.rank)); // Sort by rank if we're using fallback options
//           filteredUniversities.addAll(
//               remainingUniversities.take(3 - filteredUniversities.length));
//         }
//       } catch (e) {
//         print('Error in filtering universities: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('An error occurred while filtering universities')),
//         );
//       } finally {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     });
//   }

//   bool _isInFeeRange(String universityFee, String selectedRange) {
//     try {
//       int fee = int.parse(universityFee.replaceAll(',', ''));
//       List<int> range = selectedRange
//           .split(' - ')
//           .map((e) => int.parse(e.replaceAll(',', '')))
//           .toList();
//       return fee >= range[0] && fee <= range[1];
//     } catch (e) {
//       print('Error parsing fee range: $e');
//       return false;
//     }
//   }

//   bool _meetsPercentageCriteria(
//       String? universityPercentage, String selectedPercentage) {
//     if (universityPercentage == null) return true;
//     try {
//       return int.parse(universityPercentage.replaceAll('%', '')) <=
//           int.parse(selectedPercentage.replaceAll('%', ''));
//     } catch (e) {
//       print('Error parsing percentage: $e');
//       return false;
//     }
//   }

//   void _resetFilters() {
//     setState(() {
//       selectedCity = null;
//       selectedProgram = null;
//       selectedFees = null;
//       selectedSSC = null;
//       selectedHSC = null;
//       filteredUniversities = [];
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 const Text(
//                   'Recommend me a university',
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 CustomButton(
//                   width: 180,
//                   text: 'Get Recommendations',
//                   onPressed: _showRecommendationDialog,
//                 ),
//                 const SizedBox(height: 20),
//                 if (isLoading)
//                   const CircularProgressIndicator()
//                 else if (filteredUniversities.isNotEmpty)
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: filteredUniversities.length,
//                       itemBuilder: (context, index) {
//                         return UniversityCard(
//                             university: filteredUniversities[index]);
//                       },
//                     ),
//                   )
//                 else if (selectedCity != null ||
//                     selectedProgram != null ||
//                     selectedFees != null ||
//                     selectedSSC != null ||
//                     selectedHSC != null)
//                   _buildNoResultsMessage()
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNoResultsMessage() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
//         const SizedBox(height: 20),
//         Text(
//           'Oops! We couldn\'t find a perfect match.',
//           style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[700]),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 10),
//         Text(
//           'But don\'t worry, your dream university is out there!',
//           style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 20),
//         CustomButton(
//           width: 200,
//           text: 'Try Different Criteria',
//           onPressed: _showRecommendationDialog,
//         ),
//         const SizedBox(height: 10),
//         TextButton(
//           onPressed: _resetFilters,
//           child: Text('Clear All Filters',
//               style: TextStyle(color: Colors.blue[700])),
//         ),
//       ],
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_gator/utils/app_colors.dart';
import 'package:uni_gator/widgets/custom_button.dart';
import 'package:uni_gator/widgets/university_card.dart';

import '/model/university_model.dart';

class NeuralNode {
  Offset position;
  List<NeuralNode> connections;
  double speed;
  double direction;

  NeuralNode(this.position)
      : connections = [],
        speed = math.Random().nextDouble() * 0.5,
        direction = math.Random().nextDouble() * 2 * math.pi;
}

class UniversityRecommendation extends StatefulWidget {
  const UniversityRecommendation({super.key});

  @override
  _UniversityRecommendationState createState() => _UniversityRecommendationState();
}


class AILoadingAnimation extends StatefulWidget {
  const AILoadingAnimation({Key? key}) : super(key: key);

  @override
  _AILoadingAnimationState createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  final int numberOfDots = 6;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _animations = List.generate(numberOfDots, (index) {
      final begin = index * (1.0 / numberOfDots);
      final end = begin + 0.5;
      return TweenSequence([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 50,
        ),
      ]).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.linear),
      ));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Brain Icon
              Icon(
                Icons.psychology,
                size: 48,
                color: Colors.white.withOpacity(0.9),
              ),
              const SizedBox(height: 24),
              // Animated Dots
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(numberOfDots, (index) {
                    return AnimatedBuilder(
                      animation: _animations[index],
                      builder: (context, child) {
                        return Container(
                          width: 8,
                          height: 8 + (_animations[index].value * 16),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.3 + _animations[index].value * 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            Text(
              'AI in Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing your preferences and finding\nthe best university matches for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UniversityRecommendationState extends State<UniversityRecommendation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<NeuralNode> nodes = [];
  final int numberOfNodes = 20;
  final double connectionDistance = 100.0;

  List<University> universities = [];
  List<University> filteredUniversities = [];
  String? selectedCity;
  String? selectedProgram;
  String? selectedFees;
  String? selectedSSC;
  String? selectedHSC;
  bool isLoading = false;

  final List<String> cityOptions = [
    'Karachi',
    'Lahore',
    'Islamabad',
    'Faisalabad',
    'Jamshoro',
    'Khairpur',
  ];
  final List<String> programOptions = [
    'MBBS',
    'BBA',
    'BS Computer Science',
    'BS Engineering'
  ];
  final List<String> feeRangeOptions = [
    '50,000 - 100,000',
    '100,000 - 200,000',
    '350,000 - 1,000,000'
  ];
  final List<String> percentageOptions = ['50%', '60%', '70%', '80%'];

  @override
  void initState() {
    super.initState();
    loadJsonData();
    _setupAnimations();
    _animationController;
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize neural nodes after layout
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < numberOfNodes; i++) {
        nodes.add(NeuralNode(
          Offset(
            math.Random().nextDouble() * size.width,
            math.Random().nextDouble() * size.height,
          ),
        ));
      }

      // Create connections between nodes
      for (var node in nodes) {
        for (var otherNode in nodes) {
          if (node != otherNode) {
            double distance = (node.position - otherNode.position).distance;
            if (distance < connectionDistance) {
              node.connections.add(otherNode);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Neural Network Background
          CustomPaint(
            painter: NeuralNetworkPainter(
              nodes: nodes,
              animation: _animationController,
            ),
            size: Size.infinite,
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.85),
                  AppColors.secondary.withOpacity(0.85),
                ],
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildMainContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Text(
          'AI University Recommenderr',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Get personalized university recommendations based on your preferences',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 24),
        _buildRecommendationButton(),
      ],
    );
  }



  // Update your _buildRecommendationButton method
Widget _buildRecommendationButton() {
    return GlowingContainer(
      glowColor: Colors.blue,
      child: GestureDetector(
        onTap: 
        _showRecommendationDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology, color: Colors.white.withOpacity(0.9)),
              const SizedBox(width: 12),
              Text(
                'Get AI Recommendations',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

void _showRecommendationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('Recommend a University'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDropdown('City', selectedCity, cityOptions, (newValue) {
                    setDialogState(() => selectedCity = newValue);
                  }),
                  _buildDropdown('Program', selectedProgram, programOptions,
                      (newValue) {
                    setDialogState(() => selectedProgram = newValue);
                  }),
                  _buildDropdown('Fee Range', selectedFees, feeRangeOptions,
                      (newValue) {
                    setDialogState(() => selectedFees = newValue);
                  }),
                  _buildDropdown(
                      'SSC Percentage', selectedSSC, percentageOptions,
                      (newValue) {
                    setDialogState(() => selectedSSC = newValue);
                  }),
                  _buildDropdown(
                      'HSC Percentage', selectedHSC, percentageOptions,
                      (newValue) {
                    setDialogState(() => selectedHSC = newValue);
                  }),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Reset'),
                onPressed: () {
                  setDialogState(() {
                    selectedCity = null;
                    selectedProgram = null;
                    selectedFees = null;
                    selectedSSC = null;
                    selectedHSC = null;
                  });
                },
              ),
              TextButton(
                child: Text('Submit'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    // Update the main widget's state
                    selectedCity = selectedCity;
                    selectedProgram = selectedProgram;
                    selectedFees = selectedFees;
                    selectedSSC = selectedSSC;
                    selectedHSC = selectedHSC;
                  });
                  _getRecommendations();
                },
              ),
            ],
          );
        });
      },
    );
  }



  Widget _buildMainContent() {
    if (isLoading) {
      return _buildLoadingState();
    } else if (filteredUniversities.isNotEmpty) {
      return _buildRecommendationsList();
    } else if (selectedCity != null ||
        selectedProgram != null ||
        selectedFees != null ||
        selectedSSC != null ||
        selectedHSC != null) {
      return _buildNoResultsMessage();
    }
    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Our AI is analyzing your preferences...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
  return Container(
    width: double.infinity,
    child: Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Best Matches for You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Based on your preferences and requirements',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filteredUniversities.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildUniversityCard(filteredUniversities[index], index),
              );
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildUniversityCard(University university, int index) {
  return GlowingContainer(
    glowColor: Colors.blue,
    glowIntensity: 3.0,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          UniversityCard(university: university),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Match Score: ${university.score}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 100,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'Start your university journey',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Get personalized recommendations based on\nyour preferences and requirements',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }







 
  Future<void> loadJsonData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/university_data.json');
      final data = await json.decode(response);
      setState(() {
        universities =
            (data as List).map((item) => University.fromJson(item)).toList();
      });
    } catch (e) {
      log('Error loading university data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load university data')),
      );
    }
  }

  // Add this new method
  bool _exceedsPercentageCriteria(
      String? universityPercentage, String selectedPercentage) {
    if (universityPercentage == null) return false;
    try {
      return int.parse(universityPercentage.replaceAll('%', '')) >
          int.parse(selectedPercentage.replaceAll('%', ''));
    } catch (e) {
      log('Error parsing percentage: $e');
      return false;
    }
  }

  
  Widget _buildDropdown(String label, String? selectedValue, List<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: selectedValue,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void _getRecommendations() {
    setState(() {
      isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      try {
        List<University> cityMatches = [];
        List<University> otherMatches = [];

        // Step 1: Filter universities based on all user requirements
        for (var university in universities) {
          bool matches = (selectedProgram == null ||
                  university.programs.contains(selectedProgram)) &&
              (selectedFees == null ||
                  _isInFeeRange(university.feeStructure, selectedFees!)) &&
              (selectedSSC == null ||
                  _meetsPercentageCriteria(
                      university.minimumSSC, selectedSSC!)) &&
              (selectedHSC == null ||
                  _meetsPercentageCriteria(
                      university.minimumHSC, selectedHSC!));

          if (matches) {
            if (selectedCity == null ||
                university.campuses.contains(selectedCity)) {
              cityMatches.add(university);
            } else {
              otherMatches.add(university);
            }
          }
        }

        // Step 2: Score universities
        void scoreUniversities(List<University> unis) {
          for (var university in unis) {
            int score = 0;
            if (selectedCity != null &&
                university.campuses.contains(selectedCity)) score += 50;
            if (selectedProgram != null &&
                university.programs.contains(selectedProgram)) score += 30;
            if (selectedFees != null &&
                _isInFeeRange(university.feeStructure, selectedFees!))
              score += 20;
            if (selectedSSC != null &&
                _exceedsPercentageCriteria(university.minimumSSC, selectedSSC!))
              score += 10;
            if (selectedHSC != null &&
                _exceedsPercentageCriteria(university.minimumHSC, selectedHSC!))
              score += 10;
            university.score = score;
          }
        }

        scoreUniversities(cityMatches);
        scoreUniversities(otherMatches);

        // Step 3: Sort universities by score (descending)
        cityMatches.sort((a, b) => b.score.compareTo(a.score));
        otherMatches.sort((a, b) => b.score.compareTo(a.score));

        // Step 4: Combine results to get exactly 3 universities
        filteredUniversities = cityMatches.take(3).toList();
        if (filteredUniversities.length < 3) {
          filteredUniversities
              .addAll(otherMatches.take(3 - filteredUniversities.length));
        }

        // If we still don't have 3 universities, add any remaining universities
        if (filteredUniversities.length < 3) {
          var remainingUniversities = universities
              .where((university) => !filteredUniversities.contains(university))
              .toList();
          remainingUniversities.sort((a, b) => b.rank.compareTo(
              a.rank)); // Sort by rank if we're using fallback options
          filteredUniversities.addAll(
              remainingUniversities.take(3 - filteredUniversities.length));
        }
      } catch (e) {
        print('Error in filtering universities: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An error occurred while filtering universities')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  bool _isInFeeRange(String universityFee, String selectedRange) {
    try {
      int fee = int.parse(universityFee.replaceAll(',', ''));
      List<int> range = selectedRange
          .split(' - ')
          .map((e) => int.parse(e.replaceAll(',', '')))
          .toList();
      return fee >= range[0] && fee <= range[1];
    } catch (e) {
      print('Error parsing fee range: $e');
      return false;
    }
  }

  bool _meetsPercentageCriteria(
      String? universityPercentage, String selectedPercentage) {
    if (universityPercentage == null) return true;
    try {
      return int.parse(universityPercentage.replaceAll('%', '')) <=
          int.parse(selectedPercentage.replaceAll('%', ''));
    } catch (e) {
      print('Error parsing percentage: $e');
      return false;
    }
  }

  void _resetFilters() {
    setState(() {
      selectedCity = null;
      selectedProgram = null;
      selectedFees = null;
      selectedSSC = null;
      selectedHSC = null;
      filteredUniversities = [];
    });
  }

   

  Widget _buildNoResultsMessage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 20),
        Text(
          'Oops! We couldn\'t find a perfect match.',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          'But don\'t worry, your dream university is out there!',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        CustomButton(
          width: 200,
          text: 'Try Different Criteria',
          onPressed: _showRecommendationDialog,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: _resetFilters,
          child: Text('Clear All Filters',
              style: TextStyle(color: Colors.blue[700])),
        ),
      ],
    );
  }
}




class NeuralNetworkPainter extends CustomPainter {
  final List<NeuralNode> nodes;
  final Animation<double> animation;

  NeuralNetworkPainter({
    required this.nodes,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Update node positions
    for (var node in nodes) {
      node.position = Offset(
        (node.position.dx + math.cos(node.direction) * node.speed) % size.width,
        (node.position.dy + math.sin(node.direction) * node.speed) % size.height,
      );

      // Draw connections
      for (var connection in node.connections) {
        double distance = (node.position - connection.position).distance;
        double opacity = 1.0 - (distance / 100.0);
        opacity = opacity.clamp(0.0, 0.3);

        canvas.drawLine(
          node.position,
          connection.position,
          paint..color = Colors.white.withOpacity(opacity),
        );
      }

      // Draw nodes
      canvas.drawCircle(node.position, 3.0, nodePaint);
    }
  }

  @override
  bool shouldRepaint(NeuralNetworkPainter oldDelegate) => true;
}

class GlowingContainer extends StatelessWidget {
  final Widget child;
  final double glowIntensity;
  final Color glowColor;

  const GlowingContainer({
    Key? key,
    required this.child,
    this.glowIntensity = 5.0,
    this.glowColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.2),
            blurRadius: glowIntensity * 2,
            spreadRadius: glowIntensity / 2,
          ),
        ],
      ),
      child: child,
    );
  }
}



Widget _buildLoadingState() {
  return const Center(
    child: AILoadingAnimation(),
  );
}