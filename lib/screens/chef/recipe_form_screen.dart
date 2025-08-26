import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/recipe.dart';

class RecipeFormScreen extends ConsumerStatefulWidget {
  final Recipe? recipe; // If provided, we're editing; otherwise creating

  const RecipeFormScreen({super.key, this.recipe});

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _deliveryRadiusController = TextEditingController();

  bool _isAvailable = true;
  bool _isFeatured = false;
  DifficultyLevel _difficulty = DifficultyLevel.medium;
  SpiceLevel _spiceLevel = SpiceLevel.medium;
  String _selectedCuisine = 'Arabic';
  String _selectedCategory = 'Main Course';
  
  final List<String> _ingredients = [];
  final List<String> _instructions = [];
  final List<String> _tags = [];
  final List<File> _images = [];
  
  bool _isHalal = true;
  bool _isVegetarian = false;
  bool _isVegan = false;
  bool _isGlutenFree = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _loadRecipeData();
    }
  }

  void _loadRecipeData() {
    final recipe = widget.recipe!;
    _titleController.text = recipe.title;
    _descriptionController.text = recipe.description;
    _priceController.text = recipe.price.toString();
    _prepTimeController.text = recipe.preparationTime.toString();
    _cookingTimeController.text = recipe.cookingTime.toString();
    _servingsController.text = recipe.servings.toString();
    _isAvailable = recipe.isAvailable;
    _isFeatured = recipe.isFeatured;
    _difficulty = recipe.difficulty;
    _spiceLevel = recipe.spiceLevel;
    _selectedCuisine = recipe.cuisineType;
    _selectedCategory = recipe.category;
    
    _ingredients.clear();
    _ingredients.addAll(recipe.ingredients.map((i) => '${i.name} - ${i.quantity} ${i.unit}'));
    
    _instructions.clear();
    _instructions.addAll(recipe.instructions.map((i) => i.instruction));
    
    _tags.clear();
    _tags.addAll(recipe.tags);
    
    _isHalal = recipe.dietaryInfo.isHalal;
    _isVegetarian = recipe.dietaryInfo.isVegetarian;
    _isVegan = recipe.dietaryInfo.isVegan;
    _isGlutenFree = recipe.dietaryInfo.isGlutenFree;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    _cookingTimeController.dispose();
    _servingsController.dispose();
    _deliveryRadiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Recipe' : 'Create Recipe'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Images
              _buildSectionTitle('Images'),
              const SizedBox(height: 16),

              _buildImageUploadSection(),
              const SizedBox(height: 24),

              // Pricing and Availability
              _buildSectionTitle('Pricing & Availability'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (EGP)',
                        border: OutlineInputBorder(),
                        prefixText: 'EGP ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _deliveryRadiusController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Radius (km)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter delivery radius';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Available for Orders'),
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value ?? false;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text('Featured Recipe'),
                      value: _isFeatured,
                      onChanged: (value) {
                        setState(() {
                          _isFeatured = value ?? false;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Categories and Tags
              _buildSectionTitle('Categories & Tags'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCuisine,
                      decoration: const InputDecoration(
                        labelText: 'Cuisine Type',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Arabic', 'Egyptian', 'Lebanese', 'Syrian', 'Turkish', 'Italian', 'Indian', 'Chinese', 'Other']
                          .map((cuisine) => DropdownMenuItem(value: cuisine, child: Text(cuisine)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCuisine = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Main Course', 'Appetizer', 'Dessert', 'Beverage', 'Salad', 'Soup', 'Bread', 'Other']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildTagsSection(),
              const SizedBox(height: 24),

              // Preparation Details
              _buildSectionTitle('Preparation Details'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter prep time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Cooking Time (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cooking time';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter number of servings';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<DifficultyLevel>(
                      value: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty Level',
                        border: OutlineInputBorder(),
                      ),
                      items: DifficultyLevel.values
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _difficulty = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<SpiceLevel>(
                      value: _spiceLevel,
                      decoration: const InputDecoration(
                        labelText: 'Spice Level',
                        border: OutlineInputBorder(),
                      ),
                      items: SpiceLevel.values
                          .map((level) => DropdownMenuItem(
                                value: level,
                                child: Text(level.name.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _spiceLevel = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Dietary Information
              _buildSectionTitle('Dietary Information'),
              const SizedBox(height: 16),

              CheckboxListTile(
                title: const Text('Halal'),
                value: _isHalal,
                onChanged: (value) {
                  setState(() {
                    _isHalal = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Vegetarian'),
                value: _isVegetarian,
                onChanged: (value) {
                  setState(() {
                    _isVegetarian = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Vegan'),
                value: _isVegan,
                onChanged: (value) {
                  setState(() {
                    _isVegan = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Gluten Free'),
                value: _isGlutenFree,
                onChanged: (value) {
                  setState(() {
                    _isGlutenFree = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Ingredients
              _buildSectionTitle('Ingredients'),
              const SizedBox(height: 16),

              _buildIngredientsSection(),
              const SizedBox(height: 24),

              // Instructions
              _buildSectionTitle('Cooking Instructions'),
              const SizedBox(height: 16),

              _buildInstructionsSection(),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isEditing ? 'Update Recipe' : 'Create Recipe',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _pickImageFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('From Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_images.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _images[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Add Tag',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., spicy, traditional, quick',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_tags.contains(value)) {
                    setState(() {
                      _tags.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _tags.remove(tag);
                });
              },
            )).toList(),
          ),
      ],
    );
  }

  Widget _buildIngredientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Add Ingredient',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 2 cups rice',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_ingredients.contains(value)) {
                    setState(() {
                      _ingredients.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_ingredients.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Text('${index + 1}.'),
                title: Text(_ingredients[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _ingredients.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildInstructionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Add Instruction Step',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Heat oil in a pan',
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty && !_instructions.contains(value)) {
                    setState(() {
                      _instructions.add(value);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_instructions.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _instructions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(_instructions[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _instructions.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement API call to save recipe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.recipe != null ? 'Recipe updated successfully!' : 'Recipe created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }
}

