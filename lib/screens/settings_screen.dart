import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = true;
  bool _accessibilityModeEnabled = false;
  String _selectedLanguage = 'English';

  Color get _backgroundColor =>
      _darkModeEnabled ? const Color(0xFF0F172A) : const Color(0xFFE6F2FA);

  Color get _cardColor =>
      _darkModeEnabled ? const Color(0xFF1E293B) : Colors.white;

  Color get _primaryTextColor =>
      _darkModeEnabled ? Colors.white : const Color(0xFF2C3E50);

  Color get _accentColor =>
      _darkModeEnabled ? const Color(0xFF38BDF8) : const Color(0xFF4A90E2);

  Color get _shadowColor =>
      _darkModeEnabled ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.05);

  Color get _iconBackgroundColor =>
      _darkModeEnabled ? Colors.white.withOpacity(0.08) : const Color(0xFFADD8E6).withOpacity(0.3);

  TextStyle get _headerTextStyle => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: _primaryTextColor,
      );

  TextStyle get _cardTitleStyle => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: _primaryTextColor,
      );

  TextStyle get _valueTextStyle => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: _primaryTextColor,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
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
                      color: _accentColor,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: _headerTextStyle,
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
                          Text('Dark Mode', style: _cardTitleStyle),
                          Switch(
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() {
                                _darkModeEnabled = value;
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: _accentColor,
                            inactiveTrackColor: Colors.grey.withOpacity(0.4),
                            thumbColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : _primaryTextColor.withOpacity(0.6),
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
                          Text('Language', style: _cardTitleStyle),
                          Row(
                            children: [
                              Text(
                                _selectedLanguage,
                                style: _valueTextStyle,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: _accentColor,
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
                          Text('Accessibility Mode', style: _cardTitleStyle),
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
                            activeTrackColor: _accentColor,
                            inactiveTrackColor: Colors.grey.withOpacity(0.4),
                            thumbColor:
                                MaterialStateProperty.resolveWith<Color>(
                              (states) => states.contains(MaterialState.selected)
                                  ? Colors.white
                                  : _primaryTextColor.withOpacity(0.6),
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
                          Text('Backup & Export', style: _cardTitleStyle),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _iconBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.cloud_download,
                              color: _accentColor,
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
                          Text('About', style: _cardTitleStyle),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _iconBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.info_outline,
                              color: _accentColor,
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
    final borderRadius = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: _accentColor.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: _shadowColor,
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
                    ? const Icon(Icons.check, color: Color(0xFF4A90E2))
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

