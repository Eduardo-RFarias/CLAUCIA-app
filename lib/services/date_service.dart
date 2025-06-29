import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'localization_service.dart';

class DateService {
  static DateService? _instance;
  static DateService get instance => _instance ??= DateService._();
  DateService._();

  // Get the current locale for date formatting
  Locale get _currentLocale {
    // You can implement locale detection here or get it from your app state
    // For now, we'll use a simple approach
    return l10n.localeName == 'pt'
        ? const Locale('pt', 'BR')
        : const Locale('en', 'US');
  }

  // Get timezone offset string (e.g., "UTC-3", "UTC+0")
  String get timezoneOffset {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = (offset.inMinutes / 60).floor();
    final minutes = offset.inMinutes % 60;

    String sign = offset.isNegative ? '-' : '+';
    if (offset.isNegative) {
      // Remove the negative sign since we already have the sign
      return 'UTC$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return 'UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  // Get timezone name (e.g., "America/Sao_Paulo", "America/New_York")
  String get timezoneName {
    return DateTime.now().timeZoneName;
  }

  // Format date only (e.g., "15/12/2023" for pt-BR, "12/15/2023" for en-US)
  String formatDate(DateTime date) {
    final formatter = DateFormat.yMd(_currentLocale.toString());
    return formatter.format(date);
  }

  // Format time only (e.g., "14:30")
  String formatTime(DateTime dateTime) {
    final formatter = DateFormat.Hm(_currentLocale.toString());
    return formatter.format(dateTime);
  }

  // Format date and time (e.g., "15/12/2023 14:30")
  String formatDateTime(DateTime dateTime) {
    final dateFormatter = DateFormat.yMd(_currentLocale.toString());
    final timeFormatter = DateFormat.Hm(_currentLocale.toString());
    return '${dateFormatter.format(dateTime)} ${timeFormatter.format(dateTime)}';
  }

  // Format date and time with timezone (e.g., "15/12/2023 14:30 (UTC-3)")
  String formatDateTimeWithTimezone(DateTime dateTime) {
    return '${formatDateTime(dateTime)} ($timezoneOffset)';
  }

  // Format relative time (e.g., "2 days ago", "3 hours ago")
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      if (days == 1) {
        return l10n.yesterday;
      } else if (days < 7) {
        return l10n.daysAgo(days);
      } else if (days < 30) {
        final weeks = (days / 7).floor();
        return weeks == 1 ? l10n.weekAgo : l10n.weeksAgo(weeks);
      } else if (days < 365) {
        final months = (days / 30).floor();
        return months == 1 ? l10n.monthAgo : l10n.monthsAgo(months);
      } else {
        final years = (days / 365).floor();
        return years == 1 ? l10n.yearAgo : l10n.yearsAgo(years);
      }
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return hours == 1 ? l10n.hourAgo : l10n.hoursAgo(hours);
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return minutes == 1 ? l10n.minuteAgo : l10n.minutesAgo(minutes);
    } else {
      return l10n.justNow;
    }
  }

  // Format relative date for UI lists (e.g., "Today", "Yesterday", "2 days ago", "15/12/2023")
  String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      return l10n.today;
    } else if (difference == 1) {
      return l10n.yesterday;
    } else if (difference < 7) {
      return l10n.daysAgo(difference);
    } else {
      return formatDate(date);
    }
  }

  // Format date for input fields and displays
  String formatDateForDisplay(DateTime date) {
    return formatDate(date);
  }

  // Format full date with weekday (e.g., "Monday, December 15, 2023" for en-US)
  String formatFullDate(DateTime date) {
    final formatter = DateFormat.yMMMMEEEEd(_currentLocale.toString());
    return formatter.format(date);
  }

  // Format month and year (e.g., "December 2023" for en-US, "Dezembro 2023" for pt-BR)
  String formatMonthYear(DateTime date) {
    final formatter = DateFormat.yMMMM(_currentLocale.toString());
    return formatter.format(date);
  }

  // Get current DateTime with timezone information preserved
  DateTime now() {
    return DateTime.now();
  }

  // Convert DateTime to ISO string with timezone
  String toIsoStringWithTimezone(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  // Parse ISO string to DateTime
  DateTime parseIsoString(String isoString) {
    return DateTime.parse(isoString);
  }
}

// Extension for easier access
extension DateTimeExtensions on DateTime {
  String get formattedDate => DateService.instance.formatDate(this);
  String get formattedTime => DateService.instance.formatTime(this);
  String get formattedDateTime => DateService.instance.formatDateTime(this);
  String get formattedDateTimeWithTimezone =>
      DateService.instance.formatDateTimeWithTimezone(this);
  String get relativeTime => DateService.instance.formatRelativeTime(this);
  String get relativeDate => DateService.instance.formatRelativeDate(this);
  String get fullDate => DateService.instance.formatFullDate(this);
  String get monthYear => DateService.instance.formatMonthYear(this);
}
