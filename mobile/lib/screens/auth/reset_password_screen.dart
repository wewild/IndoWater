import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_text_field.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _token;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _extractToken();
    });
  }

  void _extractToken() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic> && args.containsKey('token')) {
      setState(() {
        _token = args['token'] as String;
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid or expired reset token. Please request a new password reset link.';
      });
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if token is available
    if (_token == null) {
      setState(() {
        _errorMessage = 'Invalid or expired reset token. Please request a new password reset link.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.resetPassword(
        token: _token!,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Password Reset Successful'),
            content: const Text('Your password has been reset successfully. You can now login with your new password.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to reset password. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.iconTheme.color,
          ),
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Constants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    'Reset Password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: Constants.marginSmall),
                  // Subtitle
                  Text(
                    'Create a new password for your account',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(Constants.paddingMedium),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: Constants.marginSmall),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Constants.marginLarge),
                  ],
                  // Password field
                  AppTextField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Password is required'),
                      MinLengthValidator(8, errorText: 'Password must be at least 8 characters'),
                      PatternValidator(r'(?=.*?[#?!@$%^&*-])', errorText: 'Password must have at least one special character'),
                      PatternValidator(r'(?=.*?[0-9])', errorText: 'Password must have at least one number'),
                      PatternValidator(r'(?=.*?[A-Z])', errorText: 'Password must have at least one uppercase letter'),
                    ]),
                    enabled: !_isLoading && _token != null,
                  ),
                  const SizedBox(height: Constants.marginLarge),
                  // Confirm password field
                  AppTextField(
                    label: 'Confirm New Password',
                    hint: 'Confirm your new password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    prefixIcon: Icons.lock,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    enabled: !_isLoading && _token != null,
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Reset password button
                  AppButton(
                    text: 'Reset Password',
                    onPressed: _isLoading || _token == null ? null : _resetPassword,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: Constants.marginLarge),
                  // Back to login
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Remember your password?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                                },
                          child: Text(
                            'Login',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}