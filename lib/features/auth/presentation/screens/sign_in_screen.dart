import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/auth_repository.dart';
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
              onRememberMeChanged: (bool val) =>
                  setState(() => _rememberMe = val),
              onObscurePasswordChanged: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.check_circle,
              size: 48,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome back!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${user.displayName ?? user.email}',
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            onPressed: () => ref.read(authRepositoryProvider).logout(),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: <Widget>[
            const OnboardingProgressBar(currentStep: 4),
            const SizedBox(height: 40),

            // App Logo/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.eco,
                size: 40,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // App Title
            Text(
              'Ghiraas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! Please sign in to continue.',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Error Message
            if (error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.error.withOpacity(0.5)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.error_outline,
                        color: colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: colorScheme.onErrorContainer,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Email Field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon:
                    Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 2),
                ),
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 16),

            // Password Field
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon:
                    Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onObscurePasswordChanged,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 2),
                ),
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 16),

            // Remember Me & Forgot Password Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: colorScheme.primary,
                        onChanged: (bool? val) =>
                            onRememberMeChanged(val ?? false),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(
                            color: colorScheme.outline, width: 2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Remember Me',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => GoRouter.of(context).go('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: loading ? null : onSignIn,
                child: loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Text(
                        'Sign In',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            Row(
              children: <Widget>[
                Expanded(
                    child:
                        Divider(color: colorScheme.outline, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                    child:
                        Divider(color: colorScheme.outline, thickness: 1)),
              ],
            ),
            const SizedBox(height: 24),

            // Google Sign In Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  foregroundColor: colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  side: BorderSide(color: colorScheme.outline, width: 1.5),
                  elevation: 0,
                ),
                onPressed: loading ? null : onSignInWithGoogle,
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.g_mobiledata,
                    size: 24,
                    color: Colors.red,
                  ),
                ),
                label: Text(
                  'Continue with Google',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Sign Up Link
            GestureDetector(
              onTap: () => GoRouter.of(context).go('/register'),
              child: RichText(
                text: TextSpan(
                  text: "Don't have an account? ",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
