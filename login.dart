import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      String message = 'Invalid username or password';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Invalid password, please try again.';
      }
      _showErrorDialog(message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorDialog("Please enter a valid email to reset password.");
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showErrorDialog("Password reset email has been sent.");
    } on FirebaseAuthException catch (e) {
      _showErrorDialog(e.message ?? "An error occurred.");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Sign out the previous user to allow account selection
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User canceled

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      // Navigate to home screen
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      _showErrorDialog("Google sign-in failed. Please try again.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.purple,
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 600;
          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isWeb ? 300 : 40, vertical: 40),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FadeInUp(
                      duration: const Duration(milliseconds: 1000),
                      child: Text("Login", style: GoogleFonts.lato(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                    const SizedBox(height: 10),
                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Text("Login to your account", style: TextStyle(fontSize: 16, color: Colors.blue[700])),
                    ),
                    const SizedBox(height: 30),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: makeInput(label: "Email", controller: _emailController),
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 1300),
                            child: makeInput(
                              label: "Password",
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text("Forgot Password?", style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    FadeInUp(
                      duration: const Duration(milliseconds: 1400),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          minimumSize: const Size(double.infinity, 55),
                        ),
                        child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blue)),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Google Sign-In
                    FadeInUp(
                      duration: const Duration(milliseconds: 1450),
                      child: ElevatedButton.icon(
                        icon: Image.asset("assets/images/google_logo.png", height: 24),
                        label: const Text("Sign in with Google"),
                        onPressed: _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sign Up
                    FadeInUp(
                      duration: const Duration(milliseconds: 1500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text("Don't have an account?", style: TextStyle(fontSize: 16, color: Colors.red)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage()));
                            },
                            child: const Text("Sign up", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    FadeInUp(
                      duration: const Duration(milliseconds: 1200),
                      child: Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/login.jpg'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget makeInput({
    required String label,
    bool obscureText = false,
    required TextEditingController controller,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) return '$label cannot be empty';
            if (label == "Email" && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
            if (label == "Password" && value.length < 6) return 'Password must be at least 6 characters';
            return null;
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
