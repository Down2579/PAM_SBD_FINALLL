import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF4A90E2);
  final Color textDark = const Color(0xFF1F2937);
  final Color textSecondary = const Color(0xFF6B7280);
  final Color bgGrey = const Color(0xFFF5F7FA);
  final Color borderGrey = const Color(0xFFE5E7EB);
  final Color successGreen = const Color(0xFF10B981);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _nameController.text = prefs.getString('username') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _phoneController.text = prefs.getString('hp') ?? '';
        _nimController.text = prefs.getString('nim') ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Name cannot be empty", isError: true);
      return;
    }

    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar("Please enter a valid email", isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Prepare data
      final updateData = {
        'nama_lengkap': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'nomor_telepon': _phoneController.text.trim(),
      };

      // Get user ID from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      if (userId == null) {
        _showSnackBar("User ID not found", isError: true);
        return;
      }

      // Call API to update profile
      final api = ApiService();
      bool success = await api.updateProfile(userId, updateData);

      if (success) {
        // Update local storage
        await prefs.setString('username', _nameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('hp', _phoneController.text);

        _showSnackBar("Profile updated successfully!", isError: false);

        // Pop after delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar("Failed to update profile", isError: true);
      }
    } catch (e) {
      print("Error saving profile: $e");
      _showSnackBar("Error: ${e.toString()}", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorRed : successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: darkNavy))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: bgGrey,
                            shape: BoxShape.circle,
                            border: Border.all(color: darkNavy, width: 2),
                          ),
                          child: Icon(Icons.person_outline, size: 60, color: darkNavy),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _nameController.text.isNotEmpty ? _nameController.text : "User",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Section
                  Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                  ),
                  const SizedBox(height: 16),

                  // NIM (Read-only)
                  _buildInputField(
                    label: "NIM",
                    controller: _nimController,
                    icon: Icons.badge_outlined,
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),

                  // Name
                  _buildInputField(
                    label: "Full Name",
                    controller: _nameController,
                    icon: Icons.person_outline,
                    hint: "Enter your full name",
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _buildInputField(
                    label: "Email Address",
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  _buildInputField(
                    label: "Phone Number",
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    hint: "Enter your phone number",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 40),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: textSecondary, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkNavy,
                            disabledBackgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          icon: _isSaving
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            _isSaving ? "Saving..." : "Save Changes",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: const Color(0xFF0369A1), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "NIM cannot be changed. Contact admin if you need to update it.",
                            style: TextStyle(fontSize: 12, color: const Color(0xFF0369A1), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary),
            prefixIcon: Icon(icon, color: darkNavy),
            filled: true,
            fillColor: readOnly ? bgGrey : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderGrey, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderGrey, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: darkNavy, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            suffixIcon: readOnly ? Icon(Icons.lock_outline, color: textSecondary, size: 18) : null,
          ),
        ),
      ],
    );
  }
}
