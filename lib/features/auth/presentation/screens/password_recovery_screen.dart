import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatelessWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF111714),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 48.0),
                        child: Text(
                          'Reset Password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF111714),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: -0.015,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    "Enter the email associated with your account and we'll send an email with instructions to reset your password.",
                    style: TextStyle(
                      color: Color(0xFF111714),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: -0.015,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: const Color(0xFFF0F4F2),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintStyle: const TextStyle(
                        color: Color(0xFF648772),
                        fontSize: 16,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF111714),
                      fontSize: 16,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement send reset link logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38E07B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Send Reset Link',
                        style: TextStyle(
                          color: Color(0xFF111714),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Back to login
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 12),
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Color(0xFF648772),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 