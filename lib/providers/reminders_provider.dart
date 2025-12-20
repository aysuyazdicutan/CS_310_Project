import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

class RemindersProvider extends ChangeNotifier {
  static const String _quietStartKey = 'reminders_quiet_start';
  static const String _quietEndKey = 'reminders_quiet_end';
  static const String _remindersListKey = 'reminders_list';

  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 8, minute: 0);
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  TimeOfDay get quietStart => _quietStart;
  TimeOfDay get quietEnd => _quietEnd;
  List<Reminder> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;

  /// Load reminders and quiet hours from SharedPreferences
  Future<void> loadFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load quiet hours
      final quietStartHour = prefs.getInt('${_quietStartKey}_hour') ?? 22;
      final quietStartMinute = prefs.getInt('${_quietStartKey}_minute') ?? 0;
      _quietStart = TimeOfDay(hour: quietStartHour, minute: quietStartMinute);

      final quietEndHour = prefs.getInt('${_quietEndKey}_hour') ?? 8;
      final quietEndMinute = prefs.getInt('${_quietEndKey}_minute') ?? 0;
      _quietEnd = TimeOfDay(hour: quietEndHour, minute: quietEndMinute);

      // Load reminders list
      final remindersJson = prefs.getString(_remindersListKey);
      if (remindersJson != null) {
        final List<dynamic> decoded = json.decode(remindersJson);
        _reminders = decoded
            .map((json) => Reminder.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading reminders: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save reminders and quiet hours to SharedPreferences
  Future<void> saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save quiet hours
      await prefs.setInt('${_quietStartKey}_hour', _quietStart.hour);
      await prefs.setInt('${_quietStartKey}_minute', _quietStart.minute);
      await prefs.setInt('${_quietEndKey}_hour', _quietEnd.hour);
      await prefs.setInt('${_quietEndKey}_minute', _quietEnd.minute);

      // Save reminders list
      final remindersJson = json.encode(
        _reminders.map((r) => r.toJson()).toList(),
      );
      await prefs.setString(_remindersListKey, remindersJson);
    } catch (e) {
      debugPrint('Error saving reminders: $e');
    }
  }

  /// Update quiet hours
  Future<void> updateQuietHours({
    required TimeOfDay start,
    required TimeOfDay end,
  }) async {
    _quietStart = start;
    _quietEnd = end;
    notifyListeners();
    await saveToStorage();
  }

  /// Add a new reminder
  Future<void> addReminder({
    required String habitId,
    required String habitTitle,
    required String habitEmoji,
    required TimeOfDay timeOfDay,
  }) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      habitId: habitId,
      habitTitle: habitTitle,
      habitEmoji: habitEmoji,
      timeOfDay: timeOfDay,
      enabled: true,
      repeatEveryDay: true,
    );

    _reminders.add(reminder);
    notifyListeners();
    await saveToStorage();
  }

  /// Remove a reminder
  Future<void> removeReminder(String reminderId) async {
    _reminders.removeWhere((r) => r.id == reminderId);
    notifyListeners();
    await saveToStorage();
  }

  /// Toggle reminder enabled state
  Future<void> toggleReminder(String reminderId) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        enabled: !_reminders[index].enabled,
      );
      notifyListeners();
      await saveToStorage();
    }
  }

  /// Update reminder time
  Future<void> updateReminderTime(String reminderId, TimeOfDay newTime) async {
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(timeOfDay: newTime);
      notifyListeners();
      await saveToStorage();
    }
  }

  /// Mark reminder as shown today
  Future<void> markShownToday(String reminderId) async {
    final today = _getTodayDateString();
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        lastShownDate: today,
        snoozedUntil: null, // Clear snooze when marking as shown
      );
      notifyListeners();
      await saveToStorage();
    }
  }

  /// Snooze reminder for 10 minutes
  Future<void> snooze(String reminderId, {int minutes = 10}) async {
    final snoozedUntil = DateTime.now().add(Duration(minutes: minutes));
    final index = _reminders.indexWhere((r) => r.id == reminderId);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        snoozedUntil: snoozedUntil,
      );
      notifyListeners();
      await saveToStorage();
    }
  }

  /// Get today's date string in YYYY-MM-DD format
  String _getTodayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check if current time is within quiet hours
  bool _isWithinQuietHours(DateTime now) {
    final nowTime = TimeOfDay.fromDateTime(now);
    final startMinutes = _quietStart.hour * 60 + _quietStart.minute;
    final endMinutes = _quietEnd.hour * 60 + _quietEnd.minute;
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;

    // Handle quiet hours that cross midnight (e.g., 22:00 - 08:00)
    if (startMinutes > endMinutes) {
      // Quiet hours cross midnight
      return nowMinutes >= startMinutes || nowMinutes < endMinutes;
    } else {
      // Quiet hours within same day
      return nowMinutes >= startMinutes && nowMinutes < endMinutes;
    }
  }

  /// Check if reminder time has passed today
  bool _isTimePassed(TimeOfDay reminderTime, DateTime now) {
    final reminderMinutes = reminderTime.hour * 60 + reminderTime.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    return nowMinutes >= reminderMinutes;
  }

  /// Get reminders that are due right now (for in-app notifications)
  List<Reminder> getDueReminders() {
    final now = DateTime.now();
    final today = _getTodayDateString();

    if (_isWithinQuietHours(now)) {
      return []; // Don't show reminders during quiet hours
    }

    return _reminders.where((reminder) {
      if (!reminder.enabled) return false;

      // Check if already shown today
      if (reminder.lastShownDate == today) return false;

      // Check if snoozed
      if (reminder.snoozedUntil != null &&
          now.isBefore(reminder.snoozedUntil!)) {
        return false;
      }

      // Check if time has passed
      if (!_isTimePassed(reminder.timeOfDay, now)) return false;

      return true;
    }).toList();
  }

  /// Get missed reminders (due earlier today but not shown)
  List<Reminder> getMissedReminders() {
    final now = DateTime.now();
    final today = _getTodayDateString();

    return _reminders.where((reminder) {
      if (!reminder.enabled) return false;

      // Must not have been shown today
      if (reminder.lastShownDate == today) return false;

      // Time must have passed
      if (!_isTimePassed(reminder.timeOfDay, now)) return false;

      // Not currently snoozed
      if (reminder.snoozedUntil != null &&
          now.isBefore(reminder.snoozedUntil!)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// Dismiss a reminder (mark as shown without action)
  Future<void> dismissReminder(String reminderId) async {
    await markShownToday(reminderId);
  }
}

