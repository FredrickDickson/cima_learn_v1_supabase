import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import '../utils/responsive.dart';
import '../widgets/loading_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _professionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _selectedCountry;
  List<String> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _professionController.dispose();
    _organizationController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final profile = await _profileService.getUserProfile(user.id);
      
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile.fullName ?? '';
          _professionController.text = profile.profession ?? '';
          _organizationController.text = profile.organization ?? '';
          _phoneController.text = profile.phoneNumber ?? '';
          _bioController.text = profile.bio ?? '';
          _selectedCountry = profile.country;
          _selectedPreferences = List.from(profile.learningPreferences);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading profile: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await _profileService.updateUserProfile(
        userId: user.id,
        fullName: _fullNameController.text.trim(),
        profession: _professionController.text.trim(),
        organization: _organizationController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        country: _selectedCountry,
        learningPreferences: _selectedPreferences,
        bio: _bioController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: 'Profile updated successfully!',
        backgroundColor: const Color(0xFFB71C1C),
        textColor: Colors.white,
      );

      await _loadUserProfile(); // Refresh profile data
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving profile: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final imageUrl = await _storageService.uploadProfileImage(user.id);
      
      if (imageUrl != null) {
        // Update the profile image in the database
        final updatedProfile = await _profileService.updateProfileImage(
          userId: user.id,
          imageUrl: imageUrl,
        );
        
        setState(() {
          _userProfile = updatedProfile;
        });

        Fluttertoast.showToast(
          msg: 'Profile image updated successfully!',
          backgroundColor: const Color(0xFFB71C1C),
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error uploading image: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving 
                  ? const LoadingWidget(size: 16, color: Colors.white)
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                _isSaving ? 'Saving...' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: LoadingWidget())
          : SingleChildScrollView(
              padding: ResponsivePadding.symmetric(context),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Profile Header
                    _buildProfileHeader(),
                    const SizedBox(height: 32),
                    
                    // Basic Information Section
                    _buildSectionTitle('Basic Information'),
                    const SizedBox(height: 16),
                    _buildBasicInfoFields(),
                    const SizedBox(height: 32),
                    
                    // Professional Information Section
                    _buildSectionTitle('Professional Information'),
                    const SizedBox(height: 16),
                    _buildProfessionalFields(),
                    const SizedBox(height: 32),
                    
                    // Learning Preferences Section
                    _buildSectionTitle('Learning Preferences'),
                    const SizedBox(height: 16),
                    _buildLearningPreferences(),
                    const SizedBox(height: 32),
                    
                    // Bio Section
                    _buildSectionTitle('About Me'),
                    const SizedBox(height: 16),
                    _buildBioField(),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFB71C1C),
                  backgroundImage: _userProfile?.profileImage != null 
                      ? NetworkImage(_userProfile!.profileImage!)
                      : null,
                  child: _userProfile?.profileImage == null
                      ? Text(
                          _userProfile?.fullName?.isNotEmpty == true 
                              ? _userProfile!.fullName![0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFB71C1C),
                      shape: BoxShape.circle,
                    ),
                    child: _isUploadingImage
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: _isUploadingImage ? null : _uploadProfileImage,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userProfile?.fullName ?? 'User',
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.heading2(context),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB71C1C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile?.email ?? '',
                    style: TextStyle(
                      fontSize: ResponsiveFontSize.body(context),
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_userProfile?.profession?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      _userProfile!.profession!,
                      style: TextStyle(
                        fontSize: ResponsiveFontSize.body(context),
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveFontSize.heading3(context),
        fontWeight: FontWeight.bold,
        color: const Color(0xFFB71C1C),
      ),
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name *',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCountry,
          decoration: InputDecoration(
            labelText: 'Country',
            prefixIcon: const Icon(Icons.public),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
          ),
          items: _profileService.getAvailableCountries().map((country) {
            return DropdownMenuItem<String>(
              value: country,
              child: Text(country),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCountry = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildProfessionalFields() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _professionController.text.isNotEmpty ? _professionController.text : null,
          decoration: InputDecoration(
            labelText: 'Profession',
            prefixIcon: const Icon(Icons.work),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
          ),
          items: _profileService.getAvailableProfessions().map((profession) {
            return DropdownMenuItem<String>(
              value: profession,
              child: Text(profession),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _professionController.text = value ?? '';
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _organizationController,
          decoration: InputDecoration(
            labelText: 'Organization/Company',
            prefixIcon: const Icon(Icons.business),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFB71C1C)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearningPreferences() {
    final preferences = _profileService.getAvailableLearningPreferences();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your preferred learning methods:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: preferences.map((preference) {
                final isSelected = _selectedPreferences.contains(preference);
                return FilterChip(
                  label: Text(preference),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedPreferences.add(preference);
                      } else {
                        _selectedPreferences.remove(preference);
                      }
                    });
                  },
                  selectedColor: const Color(0xFFB71C1C).withOpacity(0.2),
                  checkmarkColor: const Color(0xFFB71C1C),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return TextFormField(
      controller: _bioController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Bio/Description',
        hintText: 'Tell us about yourself, your interests, and goals...',
        prefixIcon: const Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB71C1C)),
        ),
        alignLabelWithHint: true,
      ),
    );
  }
}