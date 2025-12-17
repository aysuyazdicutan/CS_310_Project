import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _accessibilityModeEnabled = false;
  String _selectedLanguage = 'English';

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
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
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
                      onTap: _openLanguagePicker,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Language', style: theme.textTheme.titleLarge),
                          Row(
                            children: [
                              Text(
                                _selectedLanguage,
                                style: theme.textTheme.bodyLarge,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Accessibility Mode
                    _buildSettingCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Accessibility Mode', style: theme.textTheme.titleLarge),
                          Switch(
                            value: _accessibilityModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _accessibilityModeEnabled = value;
                              });
                              _showSnack(
                                "Accessibility mode ${value ? 'enabled' : 'disabled'}",
                              );
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
                    // Backup & Export
                    _buildSettingCard(
                      onTap: _handleBackupAndExport,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Backup & Export', style: theme.textTheme.titleLarge),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withOpacity(0.08)
                                  : const Color(0xFFADD8E6).withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_download,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
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

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleBackupAndExport() async {
    _showSnack('Preparing your backup...');
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _showSnack('Backup ready to export!');
  }

  Future<void> _openLanguagePicker() async {
    final languages = ['English', 'Türkçe', 'Deutsch', 'Español'];
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((language) {
              final isSelected = language == _selectedLanguage;
              return ListTile(
                title: Text(
                  language,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => Navigator.pop(context, language),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selected != null && selected != _selectedLanguage) {
      setState(() {
        _selectedLanguage = selected;
      });
      _showSnack('$selected selected');
    }
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

