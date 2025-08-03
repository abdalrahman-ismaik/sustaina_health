import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sustaina_health/features/auth/domain/repositories/auth_repository.dart';
import '../../data/models/auth_models.dart';
import '../providers/auth_providers.dart';
import '../providers/onboarding_progress_provider.dart';
import '../../domain/entities/user_entity.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/onboarding_progress_bar.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final AuthRepository repo = ref.read(authRepositoryProvider);
      await repo.loginWithEmailAndPassword(
        LoginRequest(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final AuthRepository repo = ref.read(authRepositoryProvider);
      await repo.loginWithGoogle();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<UserEntity?> authState = ref.watch(authStateProvider);
    
    // Set the current step to 4 for sign-in screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProgressProvider.notifier).setStep(4);
    });
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: authState.when(
          data: (UserEntity? user) {
            if (user != null) {
              return _SignedInView(user: user);
            }
            return _SignInForm(
              emailController: _emailController,
              passwordController: _passwordController,
              rememberMe: _rememberMe,
              obscurePassword: _obscurePassword,
              loading: _loading,
              error: _error,
              onRememberMeChanged: (bool val) => setState(() => _rememberMe = val),
              onObscurePasswordChanged: () => setState(() => _obscurePassword = !_obscurePassword),
              onSignIn: _signIn,
              onSignInWithGoogle: _signInWithGoogle,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, StackTrace st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _SignedInView extends ConsumerWidget {
  final UserEntity user;
  const _SignedInView({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome, ${user.displayName ?? user.email}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(authRepositoryProvider).logout(),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool obscurePassword;
  final bool loading;
  final String? error;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onObscurePasswordChanged;
  final VoidCallback onSignIn;
  final VoidCallback onSignInWithGoogle;

  const _SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.rememberMe,
    required this.obscurePassword,
    required this.loading,
    required this.error,
    required this.onRememberMeChanged,
    required this.onObscurePasswordChanged,
    required this.onSignIn,
    required this.onSignInWithGoogle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          children: <Widget>[
            // Progress bar
            const OnboardingProgressBar(currentStep: 4),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: Text(
                  'SustainaHealth',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF121714),
                    letterSpacing: -0.015,
                  ),
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  error!,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email or Username',
                  filled: true,
                  fillColor: Color(0xFFF1F4F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(color: Color(0xFF688273)),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Color(0xFFF1F4F2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                    borderSide: BorderSide.none,
                  ),
                  hintStyle: TextStyle(color: Color(0xFF688273)),
                  contentPadding: EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 0),
                  suffixIcon: IconButton(
                    icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility, color: Color(0xFF688273)),
                    onPressed: onObscurePasswordChanged,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Remember Me',
                      style: TextStyle(color: Color(0xFF121714), fontSize: 16),
                    ),
                  ),
                  Checkbox(
                    value: rememberMe,
                    activeColor: Color(0xFF94E0B2),
                    onChanged: (bool? val) => onRememberMeChanged(val ?? false),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    side: BorderSide(color: Color(0xFFDDE4E0), width: 2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF94E0B2),
                    shape: StadiumBorder(),
                    elevation: 0,
                  ),
                  onPressed: loading ? null : onSignIn,
                  child: loading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF121714)),
                        )
                      : Text(
                          'Log In',
                          style: TextStyle(
                            color: Color(0xFF121714),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: GestureDetector(
                onTap: () => GoRouter.of(context).go('/forgot-password'),
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: Color(0xFF688273),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                'Or log in with',
                style: TextStyle(
                  color: Color(0xFF121714),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFF1F4F2),
                        shape: StadiumBorder(),
                        side: BorderSide.none,
                      ),
                      onPressed: onSignInWithGoogle,
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFFF1F4F2),
                        shape: StadiumBorder(),
                        side: BorderSide.none,
                      ),
                      onPressed: () {}, // TODO: Wire up Facebook sign-in if needed
                      child: Text(
                        'Continue with Facebook',
                        style: TextStyle(
                          color: Color(0xFF121714),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () => GoRouter.of(context).go('/register'),
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Color(0xFF688273),
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}
