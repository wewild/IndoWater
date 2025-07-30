import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_text_field.dart';
import 'package:form_field_validator/form_field_validator.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _isSuccess = false;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to send reset password link. Please try again.';
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
          onPressed: () => Navigator.of(context).pop(),
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
                    'Forgot Password',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: Constants.marginSmall),
                  // Subtitle
                  Text(
                    'Enter your email to receive a password reset link',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Success message
                  if (_isSuccess) ...[
                    Container(
                      padding: const EdgeInsets.all(Constants.paddingMedium),
                      decoration: BoxDecoration(
                        color: Constants.waterSuccess.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Constants.waterSuccess,
                              ),
                              const SizedBox(width: Constants.marginSmall),
                              Expanded(
                                child: Text(
                                  'Password reset link sent!',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: Constants.waterSuccess,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Constants.marginSmall),
                          Text(
                            'We have sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions to reset your password.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.05),
                  ],
                  // Error message
                  if (_errorMessage != null && !_isSuccess) ...[
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
                  // Email field
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: MultiValidator([
                      RequiredValidator(errorText: 'Email is required'),
                      EmailValidator(errorText: 'Enter a valid email address'),
                    ]),
                    enabled: !_isLoading && !_isSuccess,
                  ),
                  SizedBox(height: size.height * 0.05),
                  // Reset password button
                  AppButton(
                    text: 'Send Reset Link',
                    onPressed: _isLoading || _isSuccess ? null : _resetPassword,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ),
                  const SizedBox(height: Constants.marginLarge),
                  // Back to login
                  if (_isSuccess) ...[
                    AppButton(
                      text: 'Back to Login',
                      type: ButtonType.outline,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      isFullWidth: true,
                    ),
                  ] else ...[
                    // Login link
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
                                    Navigator.of(context).pop();
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}