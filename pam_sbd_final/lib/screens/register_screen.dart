import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart'; // Pastikan path ini sesuai

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _namaController = TextEditingController();
  final _nimController = TextEditingController();
  final _emailController = TextEditingController();
  final _hpController = TextEditingController();
  final _passController = TextEditingController();

  // 1. VARIABLE UNTUK VISIBILITY PASSWORD
  bool _isPasswordVisible = false;

  // Colors Palette
  final Color darkBlue = const Color(0xFF2B4263);
  final Color textDark = const Color(0xFF1F1F1F);
  
  // Warna Gradasi Background
  final Color bgTop = const Color(0xFFD0E8FF); 
  final Color bgBottom = const Color(0xFF9CCBF9);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= LOGO DARI ASSETS (PERBAIKAN) =================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menggunakan Image Asset agar logo sama dengan Login Screen
                        Image.asset(
                          'assets/images/logo.png', // Pastikan file ini ada
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                        ),
                        
                        const SizedBox(height: 10),
                        
                        Text(
                          "LOST & FOUND",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                    // ================= TITLE =================
                    Text(
                      "Create a new\naccount",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================= INPUT FIELDS =================
                    
                    _buildPillInput(
                      controller: _namaController,
                      hint: "Name..",
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildPillInput(
                      controller: _nimController,
                      hint: "NIM...",
                      icon: Icons.edit_outlined,
                      keyboard: TextInputType.number,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildPillInput(
                      controller: _emailController,
                      hint: "Email...",
                      icon: Icons.alternate_email,
                      keyboard: TextInputType.emailAddress,
                      validator: (v) => !v!.contains("@") ? "Email tidak valid" : null,
                    ),
                    const SizedBox(height: 15),

                    _buildPillInput(
                      controller: _hpController,
                      hint: "Phone Number...",
                      icon: Icons.phone_android_outlined,
                      keyboard: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 15),

                    // 2. INPUT PASSWORD DENGAN TOMBOL MATA
                    _buildPillInput(
                      controller: _passController,
                      hint: "Password...",
                      icon: Icons.vpn_key_outlined,
                      
                      // Logika obscure dinamis
                      obscure: !_isPasswordVisible, 
                      
                      validator: (v) => v!.length < 6 ? "Minimal 6 karakter" : null,
                      
                      // Tambahkan Icon Mata
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: textDark.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ================= BUTTON REGISTER =================
                    auth.isLoading
                        ? Center(child: CircularProgressIndicator(color: darkBlue))
                        : SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();

                                  bool success = await auth.register(
                                    _namaController.text,
                                    _nimController.text,
                                    _emailController.text,
                                    _hpController.text,
                                    _passController.text,
                                  );

                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Registrasi Berhasil! Silakan Login."),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context, _nimController.text);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Gagal Daftar. Cek NIM/Email."),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBlue,
                                elevation: 5,
                                shadowColor: darkBlue.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                    const SizedBox(height: 25),

                    // ================= SIGN IN LINK =================
                    Center(
                      child: Row(
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
                              "Sign in",
                              style: TextStyle(
                                color: darkBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =================== CUSTOM INPUT WIDGET (PILL SHAPE) ===================
  Widget _buildPillInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isLast = false,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    Widget? suffixIcon, 
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        keyboardType: keyboard,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.bold),
          
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: Icon(icon, color: textDark.withOpacity(0.7), size: 22),
          ),
          
          suffixIcon: suffixIcon != null 
              ? Padding(padding: const EdgeInsets.only(right: 10), child: suffixIcon) 
              : null,

          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          errorStyle: TextStyle(height: 0, color: Colors.transparent),
        ),
      ),
    );
  }
}