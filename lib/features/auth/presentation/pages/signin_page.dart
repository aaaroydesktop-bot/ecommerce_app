import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/labeled_form_field.dart';
import '../../../cart/provider/cart_provider.dart';
import '../../data/demo_accounts.dart';
import '../../provider/auth_provider.dart';
import '../widgets/brand_header.dart';
import '../widgets/demo_accounts_box.dart';

/// Sign-in screen with bundled demo accounts. The class itself is now just
/// wiring — the visual blocks (header, demo chips, banner) live in dedicated
/// widgets under `presentation/widgets/`.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.redirect});

  final String? redirect;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _fillCredentials(DemoAccount account) {
    setState(() {
      _usernameController.text = account.username;
      _passwordController.text = account.password;
    });
    context.read<AuthProvider>().clearError();
  }

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (!success) return;

    if (authProvider.user != null) {
      cartProvider.userId = authProvider.user!.id;
      unawaited(cartProvider.syncWithCloud());
    }

    _showWelcomeSnackBar(authProvider);
    _navigateAfterSignIn();
  }

  void _showWelcomeSnackBar(AuthProvider authProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Welcome back, ${authProvider.user?.firstName ?? 'User'}!',
        ),
      ),
    );
  }

  void _navigateAfterSignIn() {
    final redirect = widget.redirect;
    if (redirect != null && redirect.isNotEmpty) {
      context.go(redirect);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DummyJSON Credentials'),
        content: const Text(
          'This app authenticates using DummyJSON mock API. Use one of the '
          'demo accounts listed above (e.g., emilys / emilyspass).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form validators
  // ---------------------------------------------------------------------------

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.homePath);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BrandHeader(),
                    const SizedBox(height: 28),

                    DemoAccountsBox(
                      selectedUsername: _usernameController.text,
                      onSelect: _fillCredentials,
                    ),
                    const SizedBox(height: 20),

                    if (authProvider.errorMessage != null) ...[
                      ErrorBanner(
                        message: authProvider.errorMessage!,
                        onDismiss: authProvider.clearError,
                      ),
                      const SizedBox(height: 16),
                    ],

                    LabeledFormField(
                      label: 'Username',
                      child: _buildUsernameField(authProvider),
                    ),
                    const SizedBox(height: 18),

                    LabeledFormField(
                      label: 'Password',
                      child: _buildPasswordField(authProvider),
                    ),
                    const SizedBox(height: 12),

                    _buildRememberMeRow(),
                    const SizedBox(height: 24),

                    _buildSubmitButton(authProvider),
                    const SizedBox(height: 12),
                    _buildGuestButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField(AuthProvider authProvider) {
    return TextFormField(
      controller: _usernameController,
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.text,
      autocorrect: false,
      decoration: InputDecoration(
        hintText: 'Enter username (e.g. emilys)',
        prefixIcon: const Icon(CupertinoIcons.person, size: 20),
        suffixIcon: _usernameController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  CupertinoIcons.clear_circled_solid,
                  size: 18,
                ),
                onPressed: () {
                  setState(_usernameController.clear);
                  authProvider.clearError();
                },
              )
            : null,
      ),
      onChanged: (_) {
        setState(() {});
        if (authProvider.errorMessage != null) authProvider.clearError();
      },
      validator: (v) => _requiredValidator(v, 'Username'),
    );
  }

  Widget _buildPasswordField(AuthProvider authProvider) {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleSignIn(),
      decoration: InputDecoration(
        hintText: 'Enter password (e.g. emilyspass)',
        prefixIcon: const Icon(CupertinoIcons.lock, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? CupertinoIcons.eye_slash
                : CupertinoIcons.eye,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      onChanged: (_) {
        if (authProvider.errorMessage != null) authProvider.clearError();
      },
      validator: (v) => _requiredValidator(v, 'Password'),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom-of-form rows
  // ---------------------------------------------------------------------------

  Widget _buildRememberMeRow() {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? true),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _showHelpDialog,
          child: const Text('Need Help?'),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(AuthProvider authProvider) {
    final isLoading = authProvider.isLoading;
    return FilledButton(
      onPressed: isLoading ? null : _handleSignIn,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign In'),
                SizedBox(width: 8),
                Icon(CupertinoIcons.arrow_right, size: 18),
              ],
            ),
    );
  }

  Widget _buildGuestButton() {
    return OutlinedButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRouter.homePath);
        }
      },
      child: const Text('Continue as Guest'),
    );
  }
}

/// Local helper to ignore the unawaited-future lint without importing the
/// `dart:async` namespace at the top of every widget.
void unawaited(Future<void> _) {}