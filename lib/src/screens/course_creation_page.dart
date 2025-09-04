import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_auth_service.dart';
import '../services/instructor_service.dart';

class CourseCreationPage extends StatefulWidget {
  final InstructorService instructorService;

  const CourseCreationPage({Key? key, required this.instructorService}) : super(key: key);

  @override
  State<CourseCreationPage> createState() => _CourseCreationPageState();
}

class _CourseCreationPageState extends State<CourseCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();
  final _videoUrlController = TextEditingController();
  
  String _selectedCategory = 'Arbitration';
  String _selectedLevel = 'associate';
  String _selectedDeliveryMode = 'virtual';
  List<String> _selectedSkills = [];
  List<String> _learningOutcomes = [''];
  List<String> _prerequisites = [];
  bool _isFoundational = false;

  final List<String> _categories = [
    'Arbitration',
    'Mediation',
    'Commercial Law',
    'International Trade',
    'Construction Disputes',
    'Investment Arbitration',
    'Ethics & Professional Conduct',
    'Compliance & Risk Management',
  ];

  final List<String> _levels = [
    'associate',
    'member',
    'fellow',
  ];

  final List<String> _deliveryModes = [
    'virtual',
    'in_person',
    'hybrid',
  ];

  final List<String> _availableSkills = [
    'Arbitration',
    'Mediation',
    'Negotiation',
    'Legal Research',
    'Case Analysis',
    'Commercial Law',
    'International Law',
    'Dispute Resolution',
    'Contract Law',
    'Construction Law',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Course',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your expertise with students around the world.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBasicInformation(),
                const SizedBox(height: 32),
                _buildCourseDetails(),
                const SizedBox(height: 32),
                _buildLearningOutcomes(),
                const SizedBox(height: 32),
                _buildPrerequisites(),
                const SizedBox(height: 32),
                _buildActionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Course Title *',
              hintText: 'Enter a compelling course title',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Course title is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Course Description *',
              hintText: 'Describe what students will learn',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Course description is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'CIMA Level *',
                    border: OutlineInputBorder(),
                  ),
                  items: _levels.map((level) {
                    return DropdownMenuItem(
                      value: level,
                      child: Text(level.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (₦) *',
                    hintText: '0',
                    border: OutlineInputBorder(),
                    prefixText: '₦ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Price is required';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'Enter a valid price';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _durationController,
                  decoration: const InputDecoration(
                    labelText: 'Duration (hours) *',
                    hintText: '8',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Duration is required';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'Enter valid duration';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedDeliveryMode,
            decoration: const InputDecoration(
              labelText: 'Delivery Mode *',
              border: OutlineInputBorder(),
            ),
            items: _deliveryModes.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDeliveryMode = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _videoUrlController,
            decoration: const InputDecoration(
              labelText: 'Preview Video URL',
              hintText: 'https://youtube.com/watch?v=...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Skills Covered',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableSkills.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(skill),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
                selectedColor: const Color(0xFFB71C1C).withOpacity(0.2),
                checkmarkColor: const Color(0xFFB71C1C),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Foundational Course'),
            subtitle: const Text('Mark as a foundational course for beginners'),
            value: _isFoundational,
            onChanged: (value) {
              setState(() {
                _isFoundational = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFFB71C1C),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningOutcomes() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Outcomes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _learningOutcomes.add('');
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Outcome'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What will students be able to do after completing this course?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ..._learningOutcomes.asMap().entries.map((entry) {
            final index = entry.key;
            final outcome = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: outcome,
                      decoration: InputDecoration(
                        labelText: 'Learning Outcome ${index + 1}',
                        hintText: 'Students will be able to...',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        _learningOutcomes[index] = value;
                      },
                      validator: (value) {
                        if (index == 0 && (value?.trim().isEmpty ?? true)) {
                          return 'At least one learning outcome is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (_learningOutcomes.length > 1)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _learningOutcomes.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPrerequisites() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prerequisites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _prerequisites.add('');
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Prerequisite'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'What should students know before taking this course?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (_prerequisites.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No prerequisites - This course is suitable for beginners',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            )
          else
            ..._prerequisites.asMap().entries.map((entry) {
              final index = entry.key;
              final prerequisite = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: prerequisite,
                        decoration: InputDecoration(
                          labelText: 'Prerequisite ${index + 1}',
                          hintText: 'Basic knowledge of...',
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _prerequisites[index] = value;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _prerequisites.removeAt(index);
                        });
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _formKey.currentState?.reset();
              _titleController.clear();
              _descriptionController.clear();
              _priceController.clear();
              _durationController.clear();
              _videoUrlController.clear();
              setState(() {
                _selectedCategory = 'Arbitration';
                _selectedLevel = 'associate';
                _selectedDeliveryMode = 'virtual';
                _selectedSkills.clear();
                _learningOutcomes = [''];
                _prerequisites.clear();
                _isFoundational = false;
              });
            },
            child: const Text('Clear Form'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Consumer<EnhancedAuthService>(
            builder: (context, auth, child) {
              return ElevatedButton(
                onPressed: widget.instructorService.isLoading ? null : () => _saveCourse(auth),
                child: widget.instructorService.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Course'),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _saveCourse(EnhancedAuthService auth) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Filter out empty learning outcomes and prerequisites
    final learningOutcomes = _learningOutcomes
        .where((outcome) => outcome.trim().isNotEmpty)
        .toList();
    final prerequisites = _prerequisites
        .where((prereq) => prereq.trim().isNotEmpty)
        .toList();

    final courseData = {
      'id': 'course_${DateTime.now().millisecondsSinceEpoch}',
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
      'price': double.parse(_priceController.text.trim()),
      'duration': int.parse(_durationController.text.trim()),
      'delivery_mode': _selectedDeliveryMode,
      'video_url': _videoUrlController.text.trim().isNotEmpty 
          ? _videoUrlController.text.trim() 
          : null,
      'skills': _selectedSkills,
      'learning_outcomes': learningOutcomes,
      'prerequisites': prerequisites,
      'is_foundational': _isFoundational,
      'instructor_id': auth.userId,
      'instructor': auth.displayName,
      'rating': 0.0,
      'enrollment_count': 0,
      'status': 'draft',
    };

    final courseId = await widget.instructorService.createCourse(courseData);

    if (courseId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      _formKey.currentState?.reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _durationController.clear();
      _videoUrlController.clear();
      setState(() {
        _selectedCategory = 'Arbitration';
        _selectedLevel = 'associate';
        _selectedDeliveryMode = 'virtual';
        _selectedSkills.clear();
        _learningOutcomes = [''];
        _prerequisites.clear();
        _isFoundational = false;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.instructorService.errorMessage ?? 'Failed to create course'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}