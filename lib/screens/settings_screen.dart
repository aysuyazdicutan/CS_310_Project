import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider = context.watch<SettingsProvider>();
    final darkModeEnabled = settingsProvider.darkModeEnabled;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Settings Options
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Dark Mode
                    _buildSettingCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dark Mode', style: theme.textTheme.titleLarge),
                          Switch(
                            value: darkModeEnabled,
                            onChanged: (value) {
                              settingsProvider.toggleDarkMode(value);
                            },
                            activeColor: Colors.white,
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveTrackColor: Colors.grey.withOpacity(0.4),
                            thumbColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : theme.textTheme.titleLarge?.color?.withOpacity(0.6) ?? Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Language
                    _buildSettingCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Language', style: theme.textTheme.titleLarge),
                          Text(
                            'English',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // About
                    _buildSettingCard(
                      onTap: _showAboutApp,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('About', style: theme.textTheme.titleLarge),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFFADD8E6).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({required Widget child, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  void _showAboutApp() {
    showAboutDialog(
      context: context,
      applicationName: 'Perpetua',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Perpetua Labs',
    );
  }
}

