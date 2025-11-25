import 'package:flutter/material.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<Map<String, dynamic>> _availableHabits = [];
  final List<Map<String, dynamic>> _selectedReminders = [];
  bool _hasLoadedHabits = false;

  String _quietStart = '22.00';
  String _quietEnd = '08.00';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedHabits) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List) {
      final mappedHabits = args
          .whereType<Map>()
          .map((habit) => {
                'id': habit['id']?.toString() ?? '',
                'name': habit['name']?.toString() ?? 'Habit',
                'emoji': habit['emoji']?.toString() ?? '✨',
              })
          .toList();
      _availableHabits
        ..clear()
        ..addAll(mappedHabits);
    }
    _hasLoadedHabits = true;
  }

  void _toggleReminder(int index) {
    setState(() {
      final current = _selectedReminders[index];
      _selectedReminders[index] = {
        ...current,
        'enabled': !(current['enabled'] as bool? ?? true),
      };
    });
  }

  void _showHabitPicker() {
    if (_availableHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Henüz eklenebilir bir habit yok.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Habit Seç',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableHabits.length,
                    itemBuilder: (context, index) {
                      final habit = _availableHabits[index];
                      final alreadyAdded = _selectedReminders
                          .any((reminder) => reminder['id'] == habit['id']);
                      return ListTile(
                        leading: Text(
                          habit['emoji'] as String,
                          style: const TextStyle(fontSize: 24),
                        ),
                        title: Text(
                          habit['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        trailing: alreadyAdded
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF6B46C1),
                              )
                            : const Icon(Icons.add_circle_outline),
                        onTap: alreadyAdded
                            ? null
                            : () {
                                setState(() {
                                  _selectedReminders.add({
                                    'id': habit['id'],
                                    'name': habit['name'],
                                    'emoji': habit['emoji'],
                                    'time': '08.00',
                                    'enabled': true,
                                  });
                                });
                                Navigator.pop(context);
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editQuietHour({required bool isStart}) async {
    final result = await _promptForTime(
      title: isStart ? 'Gece başlangıcı' : 'Gece bitişi',
      initialValue: isStart ? _quietStart : _quietEnd,
    );
    if (result != null) {
      setState(() {
        if (isStart) {
          _quietStart = result;
        } else {
          _quietEnd = result;
        }
      });
    }
  }

  Future<void> _editReminderTime(int index) async {
    final current = _selectedReminders[index];
    final result = await _promptForTime(
      title: '${current['name']} saati',
      initialValue: current['time'] as String,
    );
    if (result != null) {
      setState(() {
        _selectedReminders[index] = {
          ...current,
          'time': result,
        };
      });
    }
  }

  Future<String?> _promptForTime({
    required String title,
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final rootContext = context;

    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'HH.mm',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                final formatted = _formatTime(controller.text.trim());
                if (formatted == null) {
                  ScaffoldMessenger.of(rootContext).showSnackBar(
                    const SnackBar(
                      content: Text('Lütfen HH.mm formatında geçerli bir saat girin.'),
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(formatted);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  String? _formatTime(String value) {
    if (value.isEmpty) return null;
    final sanitized = value.replaceAll(':', '.');
    final parts = sanitized.split('.');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString.$minuteString';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F2FA),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF6B46C1),
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Reminders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Quiet Hours Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5DC),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiet Hours',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () => _editQuietHour(isStart: true),
                          child: _QuietHourChip(
                            icon: Icons.nightlight_round,
                            label: _quietStart,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _editQuietHour(isStart: false),
                          child: _QuietHourChip(
                            icon: Icons.wb_sunny,
                            label: _quietEnd,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Reminders List
            Expanded(
              child: _selectedReminders.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: Text(
                          'Henüz bir hatırlatma eklemedin. Aşağıdaki + ile habit seçebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: _selectedReminders.length,
                      itemBuilder: (context, index) {
                        final reminder = _selectedReminders[index];
                        final emoji = reminder['emoji'] as String? ?? '📝';
                        final name = reminder['name'] as String? ?? 'Habit';
                        final time = reminder['time'] as String? ?? '00.00';
                        final isEnabled = reminder['enabled'] as bool? ?? true;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Emoji
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F2FA),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Title and Time
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FontStyle.italic,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () => _editReminderTime(index),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5DC),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          time,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF2C3E50),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Toggle Switch
                              Switch(
                                value: isEnabled,
                                onChanged: (_) => _toggleReminder(index),
                                activeColor: const Color(0xFF6B46C1),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            // Add Button
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: _showHabitPicker,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF2C3E50),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF2C3E50),
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietHourChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuietHourChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2C3E50),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}

