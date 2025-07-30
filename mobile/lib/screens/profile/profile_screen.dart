import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:indowater_mobile/providers/auth_provider.dart';
import 'package:indowater_mobile/providers/theme_provider.dart';
import 'package:indowater_mobile/providers/language_provider.dart';
import 'package:indowater_mobile/utils/app_routes.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';
import 'package:indowater_mobile/components/app_card.dart';
import 'package:indowater_mobile/components/app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = await authProvider.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _userProfile = user?.toJson();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showLogoutConfirmationDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: Text(
              'Logout',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppTopBar(title: 'Profile'),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: Constants.marginMedium),
                      Text(
                        'Error loading profile',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Constants.marginSmall),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Constants.paddingLarge),
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: Constants.marginLarge),
                      AppButton(
                        text: 'Retry',
                        onPressed: _loadUserProfile,
                        icon: Icons.refresh,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.paddingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile header
                        AppCard(
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _getInitials(),
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: Constants.marginLarge),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _userProfile?['name'] ?? 'User',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userProfile?['email'] ?? 'user@example.com',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userProfile?['phone'] ?? '-',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Constants.marginLarge),
                        // Account settings
                        Text(
                          'Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        _buildSettingsItem(
                          icon: Icons.person,
                          title: 'Edit Profile',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.editProfile);
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.changePassword);
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.notifications);
                          },
                        ),
                        const SizedBox(height: Constants.marginLarge),
                        // App settings
                        Text(
                          'Settings',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        _buildSettingsItem(
                          icon: Icons.language,
                          title: 'Language',
                          trailing: DropdownButton<String>(
                            value: languageProvider.language,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'en',
                                child: Text('English'),
                              ),
                              DropdownMenuItem(
                                value: 'id',
                                child: Text('Indonesia'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                languageProvider.setLanguage(value);
                              }
                            },
                          ),
                          onTap: () {},
                        ),
                        _buildSettingsItem(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          trailing: Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                            },
                            activeColor: theme.primaryColor,
                          ),
                          onTap: () {},
                        ),
                        const SizedBox(height: Constants.marginLarge),
                        // Support
                        Text(
                          'Support',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        _buildSettingsItem(
                          icon: Icons.help,
                          title: 'Help Center',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.help);
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.info,
                          title: 'About',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.about);
                          },
                        ),
                        const SizedBox(height: Constants.marginLarge),
                        // Logout button
                        AppButton(
                          text: 'Logout',
                          type: ButtonType.outline,
                          onPressed: _showLogoutConfirmationDialog,
                          icon: Icons.logout,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: Constants.marginMedium),
                        // App version
                        Center(
                          child: Text(
                            'Version ${Constants.appVersion} (${Constants.appBuildNumber})',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: Constants.marginSmall),
                        Center(
                          child: Text(
                            Constants.appCopyright,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Constants.borderRadiusMedium),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Constants.paddingSmall),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(width: Constants.marginMedium),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: Constants.iconSizeSmall,
                  color: theme.hintColor,
                ),
          ],
        ),
      ),
    );
  }

  String _getInitials() {
    final name = _userProfile?['name'] ?? 'User';
    final nameParts = name.split(' ');
    
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    } else {
      return 'U';
    }
  }
}