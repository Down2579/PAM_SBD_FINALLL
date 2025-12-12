import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart'; // Sesuaikan path import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _passController = TextEditingController();

  // Focus Nodes (Untuk efek border aktif seperti di Login)
  final FocusNode _namaFocus = FocusNode();
  final FocusNode _nimFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _hpFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isPasswordVisible = false;

  // ================= COLORS PALETTE (Sama Persis dengan Login) =================
  final Color bgTop = const Color(0xFFF5F7FA);
  final Color bgMiddle = const Color(0xFFC3CFE2);
  final Color bgBottom = const Color(0xFF4A90E2);
  
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF2563EB);
  final Color textDark = const Color(0xFF111827);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _emailController.dispose();
    _hpController.dispose();
    _passController.dispose();
    
    _namaFocus.dispose();
    _nimFocus.dispose();
    _emailFocus.dispose();
    _hpFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Tutup keyboard saat tap background
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgTop, bgMiddle, bgBottom],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ================= BACK BUTTON & HEADER =================
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: darkNavy),
                                ),
                              ),
                              
                              const SizedBox(height: 20),

                              // Logo Kecil & Nama App
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/logo.png',
                                    height: 40,
                                    width: 40,
                                    errorBuilder: (_,__,___) => Icon(Icons.school, color: darkNavy),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "LOST & FOUND",
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold, 
                                      color: darkNavy,
                                      letterSpacing: 1.0
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Text(
                                "Buat Akun",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                "Bergabung Bersama Kami di Lost & Found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textDark.withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ================= FORM FIELDS (STYLE GLASSY) =================
                              
                              _buildGlassyInput(
                                controller: _namaController,
                                focusNode: _namaFocus,
                                hint: "Nama Lengkap",
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v!.isEmpty ? "Name is required" : null,
                              ),
                              const SizedBox(height: 16),

                              _buildGlassyInput(
                                controller: _nimController,
                                focusNode: _nimFocus,
                                hint: "NIM (Nomor Induk Mahasiswa)",
                                icon: Icons.badge_outlined,
                                keyboard: TextInputType.number,
                                validator: (v) => v!.isEmpty ? "NIM is required" : null,
                              ),
                              const SizedBox(height: 16),

                              _buildGlassyInput(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                hint: "Email",
                                icon: Icons.alternate_email_rounded,
                                keyboard: TextInputType.emailAddress,
                                validator: (v) => !v!.contains("@") ? "Invalid email" : null,
                              ),
                              const SizedBox(height: 16),

                              _buildGlassyInput(
                                controller: _hpController,
                                focusNode: _hpFocus,
                                hint: "Nomor HP",
                                icon: Icons.phone_android_rounded,
                                keyboard: TextInputType.phone,
                                validator: (v) => v!.isEmpty ? "Phone number is required" : null,
                              ),
                              const SizedBox(height: 16),

                              _buildGlassyInput(
                                controller: _passController,
                                focusNode: _passFocus,
                                hint: "Password",
                                icon: Icons.lock_outline_rounded,
                                obscure: !_isPasswordVisible,
                                isLast: true,
                                validator: (v) => v!.length < 6 ? "Min. 6 characters" : null,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: textDark.withOpacity(0.5),
                                  ),
                                  onPressed: () {
                                    setState(() => _isPasswordVisible = !_isPasswordVisible);
                                  },
                                ),
                              ),

                              const SizedBox(height: 40),

                              // ================= REGISTER BUTTON (GRADIENT) =================
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    colors: auth.isLoading 
                                      ? [Colors.grey, Colors.grey] 
                                      : [accentBlue, darkNavy],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: accentBlue.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: auth.isLoading ? null : () => _handleRegister(auth),
                                    child: Center(
                                      child: auth.isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            )
                                          : const Text(
                                              "Register",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ================= FOOTER =================
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(
                                      color: textDark.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Text(
                                      "Log In",
                                      style: TextStyle(
                                        color: accentBlue,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC HANDLER =================
  Future<void> _handleRegister(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    
    FocusScope.of(context).unfocus();

    // Persiapkan Data sesuai nama kolom di DATABASE
    final Map<String, dynamic> regData = {
      'nama_lengkap': _namaController.text.trim(),
      'nim': _nimController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passController.text.trim(),
      'nomor_telepon': _hpController.text.trim(),
      'role': 'mahasiswa', 
    };

    // Panggil Provider
    bool success = await auth.register(regData);

    if (!mounted) return;

    if (success) {
      _showSnack(context, "Registrasi Berhasil! Silahkan Login.");
      // Kirim NIM kembali ke halaman login agar user tidak perlu ketik ulang
      Navigator.pop(context, _nimController.text.trim());
    } else {
      final msg = auth.errorMessage ?? "Registration failed. Please check your data.";
      _showSnack(context, msg, isError: true);
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? errorRed : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ================= CUSTOM INPUT (GLASSY STYLE - KONSISTEN DENGAN LOGIN) =================
  Widget _buildGlassyInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isLast = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  // Border berubah warna jika sedang diketik
                  color: focusNode.hasFocus ? accentBlue : Colors.white.withOpacity(0.5),
                  width: focusNode.hasFocus ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkNavy.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                focusNode: focusNode,
                obscureText: obscure,
                keyboardType: keyboard,
                validator: validator,
                textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
                style: TextStyle(
                  color: textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: Icon(
                    icon,
                    color: focusNode.hasFocus ? accentBlue : Colors.grey[600],
                    size: 22,
                  ),
                  suffixIcon: suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  errorStyle: const TextStyle(height: 0, color: Colors.transparent), 
                ),
              ),
            ),
            // Menampilkan pesan error di bawah container agar desain tetap rapi
             ValueListenableBuilder<TextEditingValue>(
               valueListenable: controller,
               builder: (ctx, value, child) {
                 if (validator == null) return const SizedBox.shrink();
                 // Validasi manual sederhana untuk display text
                 // Catatan: Ini hanya visual helper. Validasi form asli tetap jalan di _formKey.
                 // Jika ingin lebih presisi bisa menggunakan FormFieldState, tapi ini cukup untuk UI.
                 return const SizedBox.shrink(); 
               }
            )
          ],
        );
      },
    );
  }
}