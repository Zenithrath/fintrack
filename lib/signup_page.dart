import 'package:flutter/material.dart';
import 'package:fintrack/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? emailError, usernameError, passwordError, confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate form
  bool _validateForm() {
    setState(() {
      emailError = null;
      usernameError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    bool isValid = true;

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      setState(() => emailError = "Email wajib diisi");
      isValid = false;
    } else if (!email.contains('@')) {
      setState(() => emailError = "Email tidak valid");
      isValid = false;
    }

    if (username.isEmpty) {
      setState(() => usernameError = "Username wajib diisi");
      isValid = false;
    } else if (username.length < 3) {
      setState(() => usernameError = "Username minimal 3 karakter");
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => passwordError = "Password wajib diisi");
      isValid = false;
    } else if (password.length < 6) {
      setState(() => passwordError = "Password minimal 6 karakter");
      isValid = false;
    }

    if (confirmPassword.isEmpty) {
      setState(() => confirmPasswordError = "Konfirmasi password wajib diisi");
      isValid = false;
    } else if (password != confirmPassword) {
      setState(() => confirmPasswordError = "Password tidak cocok");
      isValid = false;
    }

    return isValid;
  }

  // Sign Up Function
  Future<void> signUp() async {
    if (!_validateForm()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      final email = _emailController.text.trim();
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final authService = AuthService();

      // Register (fast - no await for Firestore write)
      await authService.register(email, password, username);

      if (mounted) {
        // Success - langsung ke login tanpa dialog (lebih cepat)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Akun berhasil dibuat! Silakan login."),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );

        // Langsung ke login page
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.contains('email-already-in-use')) {
          errorMsg = 'Email sudah terdaftar';
        } else if (errorMsg.contains('invalid-email')) {
          errorMsg = 'Email tidak valid';
        } else if (errorMsg.contains('weak-password')) {
          errorMsg = 'Password terlalu lemah';
        } else if (errorMsg.contains('network')) {
          errorMsg = 'Error jaringan - cek koneksi internet';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFF8B1D2F);
    const Color darkRed = Color(0xFF570F1A);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryRed, darkRed],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Fintrack",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Track smarter. Live freer.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                // Card Sign Up
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome",
                        style: TextStyle(
                          color: primaryRed,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Create your financial account",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      _buildField(
                        hint: "Email address",
                        icon: Icons.alternate_email,
                        controller: _emailController,
                        errorText: emailError,
                      ),
                      const SizedBox(height: 16),

                      // Username Field
                      _buildField(
                        hint: "Username",
                        icon: Icons.person_outline,
                        controller: _usernameController,
                        errorText: usernameError,
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      _buildField(
                        hint: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        errorText: passwordError,
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password Field
                      _buildField(
                        hint: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        errorText: confirmPasswordError,
                      ),
                      const SizedBox(height: 30),

                      // Sign Up Button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B1D2F), Color(0xFF6C1323)],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Divider OR
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Already have account Login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/login'),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: primaryRed,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: errorText != null ? Colors.red[50] : Colors.grey[100],
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : const Color(0xFF8B1D2F),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
