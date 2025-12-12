import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart'; 
import 'register_screen.dart';
import 'home_screen.dart';
import 'admin/admin_main_screen.dart'; // <--- 1. TAMBAHKAN IMPORT INI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers
  final _nimController = TextEditingController();
  final _passController = TextEditingController();

  // Focus Nodes untuk efek UI saat mengetik
  final FocusNode _nimFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

  bool _isPasswordVisible = false;

  // ================= COLORS PALETTE =================
  final Color bgTop = const Color(0xFFF5F7FA);
  final Color bgMiddle = const Color(0xFFC3CFE2); 
  final Color bgBottom = const Color(0xFF4A90E2);
  
  final Color darkNavy = const Color(0xFF2B4263);
  final Color accentBlue = const Color(0xFF2563EB); 
  final Color textDark = const Color(0xFF111827);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  void dispose() {
    _nimController.dispose();
    _passController.dispose();
    _nimFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), 
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
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 50),

                            // ================= LOGO SECTION =================
                            FadeInImage(
                              placeholder: const AssetImage('assets/images/placeholder_logo.png'), 
                              image: const AssetImage('assets/images/logo.png'),
                              height: 120,
                              width: 120,
                              fit: BoxFit.contain,
                              imageErrorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: darkNavy, width: 2)
                                  ),
                                  child: Icon(Icons.school_outlined, size: 50, color: darkNavy),
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            // ================= HEADLINE =================
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selamat Datang,",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: textDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Log in untuk masuk ke Lost & Found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textDark.withOpacity(0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),

                            // ================= FORMS =================
                            _buildGlassyInput(
                              controller: _nimController,
                              focusNode: _nimFocus,
                              hint: "NIM / Email",
                              icon: Icons.person_outline_rounded,
                              keyboard: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 20),

                            _buildGlassyInput(
                              controller: _passController,
                              focusNode: _passFocus,
                              hint: "Password",
                              icon: Icons.lock_outline_rounded,
                              obscure: !_isPasswordVisible,
                              isLast: true, 
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: textDark.withOpacity(0.5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: darkNavy, 
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(),

                            // ================= BUTTON SECTION =================
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
                                  onTap: auth.isLoading ? null : () => _handleLogin(auth),
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
                                            "Log In",
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
                                  "Belum punya akun? ",
                                  style: TextStyle(
                                    color: textDark.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const RegisterScreen(),
                                      ),
                                    );
                                    
                                    if (result != null && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Registration successful! Please login.")),
                                      );
                                    }
                                  },
                                  child: Text(
                                    "Register",
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ================= LOGIC LOGIN (MODIFIKASI DI SINI) =================
  Future<void> _handleLogin(AuthProvider auth) async {
    if (_nimController.text.trim().isEmpty || _passController.text.trim().isEmpty) {
      _showSnack(context, "Please enter your NIM and Password", isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    bool success = await auth.login(
      _nimController.text.trim(),
      _passController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // --- 2. LOGIC PEMBEDAM ROLE ---
      final user = auth.currentUser;
      
      if (user != null && user.role == 'admin') {
        // Jika Admin -> Ke Admin Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminMainScreen()),
        );
      } else {
        // Jika User Biasa -> Ke Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
      // -----------------------------
    } else {
      final msg = auth.errorMessage ?? "Login failed. Please check your connection.";
      _showSnack(context, msg, isError: true);
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: isError ? errorRed : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildGlassyInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isLast = false,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return AnimatedBuilder(
      animation: focusNode,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
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
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscure,
            keyboardType: keyboard,
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
            ),
          ),
        );
      },
    );
  }
}