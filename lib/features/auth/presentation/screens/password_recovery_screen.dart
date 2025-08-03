import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_providers.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  const PasswordRecoveryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends ConsumerState<PasswordRecoveryScreen> {
  final TextEditingController emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _sendResetLink() async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await ref.read(authRepositoryProvider).sendPasswordResetEmail(emailController.text.trim());
      setState(() {
        _message = 'Reset link sent! Check your email.';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 32, bottom: 16),
                  child: Text(
                    'Reset Password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111714),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.015,
                    ),
                  ),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _sendResetLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38E07B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF111714))
                          : const Text(
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
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _message!.contains('sent') ? Colors.green : Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    GoRouter.of(context).go('/login'); // Back to login
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
          ),
        ),
      ),
    );
  }
} 