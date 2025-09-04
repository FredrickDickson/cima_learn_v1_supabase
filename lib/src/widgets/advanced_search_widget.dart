import 'package:flutter/material.dart';
import '../models/cima_course.dart';
import '../utils/responsive.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;

  const AdvancedSearchWidget({
    Key? key,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
  final _searchController = TextEditingController();
  CIMALevel? _selectedLevel;
  CourseCategory? _selectedCategory;
  String? _selectedDeliveryMode;
  bool _foundationalOnly = false;
  double _maxPrice = 3000.0;
  RangeValues _durationRange = const RangeValues(1, 12);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = <String, dynamic>{
      'query': _searchController.text.trim(),
      'level': _selectedLevel,
      'category': _selectedCategory,
      'deliveryMode': _selectedDeliveryMode,
      'isFoundational': _foundationalOnly ? true : null,
      'maxPrice': _maxPrice,
      'minDuration': _durationRange.start.round(),
      'maxDuration': _durationRange.end.round(),
    };
    
    // Remove null values
    filters.removeWhere((key, value) => value == null || (value is String && value.isEmpty));
    
    widget.onFiltersChanged(filters);
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedLevel = null;
      _selectedCategory = null;
      _selectedDeliveryMode = null;
      _foundationalOnly = false;
      _maxPrice = 3000.0;
      _durationRange = const RangeValues(1, 12);
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ResponsivePadding.symmetric(context, 
        mobileHorizontal: 16, 
        tabletHorizontal: 24, 
        desktopHorizontal: 32
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: InputDecoration(
                hintText: 'search for courses enrolled...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB71C1C)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Filter Options
          Responsive(
            mobile: _buildMobileFilters(),
            desktop: _buildDesktopFilters(),
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Filters'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.tune),
                label: const Text('Apply Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        _buildLevelCategoryRow(),
        const SizedBox(height: 16),
        _buildDeliveryModeRow(),
        const SizedBox(height: 16),
        _buildPriceSlider(),
        const SizedBox(height: 16),
        _buildDurationSlider(),
        const SizedBox(height: 16),
        _buildFoundationalSwitch(),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLevelDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildCategoryDropdown()),
            const SizedBox(width: 16),
            Expanded(child: _buildDeliveryModeDropdown()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(flex: 2, child: _buildPriceSlider()),
            const SizedBox(width: 32),
            Expanded(flex: 2, child: _buildDurationSlider()),
            const SizedBox(width: 32),
            Expanded(child: _buildFoundationalSwitch()),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelCategoryRow() {
    return Row(
      children: [
        Expanded(child: _buildLevelDropdown()),
        const SizedBox(width: 12),
        Expanded(child: _buildCategoryDropdown()),
      ],
    );
  }

  Widget _buildDeliveryModeRow() {
    return Row(
      children: [
        Expanded(child: _buildDeliveryModeDropdown()),
        const SizedBox(width: 12),
        Expanded(child: Container()), // Spacer
      ],
    );
  }

  Widget _buildLevelDropdown() {
    return DropdownButtonFormField<CIMALevel>(
      value: _selectedLevel,
      decoration: InputDecoration(
        labelText: 'Level',
        prefixIcon: const Icon(Icons.school),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
      ),
      items: CIMALevel.values.map((level) {
        return DropdownMenuItem<CIMALevel>(
          value: level,
          child: Text(_getLevelDisplayName(level)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedLevel = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<CourseCategory>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
      ),
      items: CourseCategory.values.map((category) {
        return DropdownMenuItem<CourseCategory>(
          value: category,
          child: Text(_getCategoryDisplayName(category)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildDeliveryModeDropdown() {
    final modes = ['Virtual', 'In-Person', 'Hybrid'];
    
    return DropdownButtonFormField<String>(
      value: _selectedDeliveryMode,
      decoration: InputDecoration(
        labelText: 'Delivery Mode',
        prefixIcon: const Icon(Icons.computer),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
      ),
      items: modes.map((mode) {
        return DropdownMenuItem<String>(
          value: mode.toLowerCase(),
          child: Text(mode),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDeliveryMode = value;
        });
        _applyFilters();
      },
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max Price: £${_maxPrice.round()}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxPrice,
          min: 0,
          max: 3000,
          divisions: 30,
          activeColor: const Color(0xFFB71C1C),
          onChanged: (value) {
            setState(() {
              _maxPrice = value;
            });
          },
          onChangeEnd: (value) => _applyFilters(),
        ),
      ],
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration: ${_durationRange.start.round()} - ${_durationRange.end.round()} days',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _durationRange,
          min: 1,
          max: 12,
          divisions: 11,
          activeColor: const Color(0xFFB71C1C),
          onChanged: (values) {
            setState(() {
              _durationRange = values;
            });
          },
          onChangeEnd: (values) => _applyFilters(),
        ),
      ],
    );
  }

  Widget _buildFoundationalSwitch() {
    return SwitchListTile(
      title: const Text(
        'Foundational Only',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Show only beginner-friendly courses'),
      value: _foundationalOnly,
      activeColor: const Color(0xFFB71C1C),
      onChanged: (value) {
        setState(() {
          _foundationalOnly = value;
        });
        _applyFilters();
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  String _getLevelDisplayName(CIMALevel level) {
    switch (level) {
      case CIMALevel.associate:
        return 'Associate (ACIMArb)';
      case CIMALevel.member:
        return 'Member (MCIMArb)';
      case CIMALevel.fellow:
        return 'Fellow (FCIMArb)';
    }
  }

  String _getCategoryDisplayName(CourseCategory category) {
    switch (category) {
      case CourseCategory.adr:
        return 'Alternative Dispute Resolution';
      case CourseCategory.arbitration:
        return 'International Arbitration';
      case CourseCategory.mediation:
        return 'Mediation';
      case CourseCategory.construction:
        return 'Construction Disputes';
      case CourseCategory.commercial:
        return 'Commercial Law';
      case CourseCategory.maritime:
        return 'Maritime Arbitration';
      case CourseCategory.investment:
        return 'Investment Disputes';
      case CourseCategory.sports:
        return 'Sports Arbitration';
      case CourseCategory.technology:
        return 'Technology & IP';
    }
  }
}