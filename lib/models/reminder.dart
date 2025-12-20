import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String habitId;
  final String habitTitle;
  final String habitEmoji;
  final TimeOfDay timeOfDay;
  final bool enabled;
  final bool repeatEveryDay;
  final String? lastShownDate; // Format: "YYYY-MM-DD"
  final DateTime? snoozedUntil;

  Reminder({
    required this.id,
    required this.habitId,
    required this.habitTitle,
    required this.habitEmoji,
    required this.timeOfDay,
    this.enabled = true,
    this.repeatEveryDay = true,
    this.lastShownDate,
    this.snoozedUntil,
  });

  // Convert to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'habitTitle': habitTitle,
      'habitEmoji': habitEmoji,
      'hour': timeOfDay.hour,
      'minute': timeOfDay.minute,
      'enabled': enabled,
      'repeatEveryDay': repeatEveryDay,
      'lastShownDate': lastShownDate,
      'snoozedUntil': snoozedUntil?.toIso8601String(),
    };
  }

  // Create from JSON
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      habitTitle: json['habitTitle'] as String,
      habitEmoji: json['habitEmoji'] as String? ?? '✨',
      timeOfDay: TimeOfDay(
        hour: json['hour'] as int,
        minute: json['minute'] as int,
      ),
      enabled: json['enabled'] as bool? ?? true,
      repeatEveryDay: json['repeatEveryDay'] as bool? ?? true,
      lastShownDate: json['lastShownDate'] as String?,
      snoozedUntil: json['snoozedUntil'] != null
          ? DateTime.parse(json['snoozedUntil'] as String)
          : null,
    );
  }

  // Create a copy with updated fields
  Reminder copyWith({
    String? id,
    String? habitId,
    String? habitTitle,
    String? habitEmoji,
    TimeOfDay? timeOfDay,
    bool? enabled,
    bool? repeatEveryDay,
    String? lastShownDate,
    DateTime? snoozedUntil,
  }) {
    return Reminder(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      habitTitle: habitTitle ?? this.habitTitle,
      habitEmoji: habitEmoji ?? this.habitEmoji,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      enabled: enabled ?? this.enabled,
      repeatEveryDay: repeatEveryDay ?? this.repeatEveryDay,
      lastShownDate: lastShownDate ?? this.lastShownDate,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
    );
  }
}

