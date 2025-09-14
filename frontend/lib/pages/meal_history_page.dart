import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calorie_tracking_app/models/meal.dart';
import 'package:calorie_tracking_app/services/meal_service.dart';

class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key});

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  List<Meal> _meals = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final meals = await MealService.getMealHistory();
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMeal(Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MealService.deleteMeal(meal.id);
        await _loadMeals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meal deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete meal: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMeals,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading meals',
              style: TextStyle(
                fontSize: 18,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_meals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No meals yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Upload your first meal to get started!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMeals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _meals.length,
        itemBuilder: (context, index) {
          final meal = _meals[index];
          return _buildMealCard(meal);
        },
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (meal.imagePath.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(meal.imagePath),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calories and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${meal.calories.toStringAsFixed(0)} cal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple.shade700,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(meal.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Comments
                if (meal.comments != null && meal.comments!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meal.comments!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Gemini analysis
                if (meal.geminiAnalysis != null && meal.geminiAnalysis!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.psychology,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Analysis',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meal.geminiAnalysis!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 12),
                
                // Delete button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _deleteMeal(meal),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
