import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class CourseFiltersWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFiltersChanged;
  final Map<String, dynamic> initialFilters;

  const CourseFiltersWidget({
    Key? key,
    required this.onFiltersChanged,
    this.initialFilters = const {},
  }) : super(key: key);

  @override
  State<CourseFiltersWidget> createState() => _CourseFiltersWidgetState();
}

class _CourseFiltersWidgetState extends State<CourseFiltersWidget> {
  Map<String, dynamic> _filters = {};
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.initialFilters);
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.isEmpty)) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
    widget.onFiltersChanged(_filters);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
    });
    widget.onFiltersChanged(_filters);
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _filters.isNotEmpty;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter Toggle Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    color: const Color(0xFFB71C1C),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                  if (hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB71C1C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_filters.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: _clearAllFilters,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: const Text('Clear All'),
                    ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // Filter Content
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  if (Responsive.isMobile(context))
                    _buildMobileFilters()
                  else
                    _buildDesktopFilters(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPricingFilter()),
        const SizedBox(width: 16),
        Expanded(child: _buildLanguageFilter()),
        const SizedBox(width: 16),
        Expanded(child: _buildQualityFilter()),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        _buildPricingFilter(),
        const SizedBox(height: 16),
        _buildLanguageFilter(),
        const SizedBox(height: 16),
        _buildQualityFilter(),
      ],
    );
  }

  Widget _buildPricingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('Free', 'price_free'),
            _buildFilterChip('Under ₦50,000', 'price_under_50k'),
            _buildFilterChip('₦50,000 - ₦200,000', 'price_50k_200k'),
            _buildFilterChip('₦200,000+', 'price_over_200k'),
          ],
        ),
      ],
    );
  }

  Widget _buildLanguageFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Language',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('English', 'lang_en'),
            _buildFilterChip('French', 'lang_fr'),
            _buildFilterChip('Arabic', 'lang_ar'),
            _buildFilterChip('Spanish', 'lang_es'),
          ],
        ),
      ],
    );
  }

  Widget _buildQualityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('Highest Rated (4.5+ ⭐)', 'quality_top_rated'),
            _buildFilterChip('Most Popular', 'quality_popular'),
            _buildFilterChip('Recently Updated', 'quality_updated'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String key) {
    final isSelected = _filters.containsKey(key);
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        _updateFilter(key, selected ? true : null);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFFB71C1C),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFFB71C1C) : Colors.grey[300]!,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}