import 'package:device_calendar/device_calendar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/story.dart';

/// Time window for an event, by weekday (hours in local time).
/// Mon/Wed/Fri 14-20, Tue/Thu 12-18, Sat/Sun 08-12.
(int, int) slotFor(DateTime day) => switch (day.weekday) {
  DateTime.saturday || DateTime.sunday => (8, 12),
  DateTime.tuesday || DateTime.thursday => (12, 18),
  _ => (14, 20),
};

class CalendarService {
  final _plugin = DeviceCalendarPlugin();

  /// Adds [story] to the device calendar on [day]. Returns null on success,
  /// or a message to show the user.
  Future<String?> addStory(Story story, DateTime day) async {
    var perm = await _plugin.hasPermissions();
    if (perm.data != true) {
      perm = await _plugin.requestPermissions();
      if (perm.data != true) return 'Calendar permission was denied.';
    }

    final calendarId = await _writableCalendarId();
    if (calendarId == null) return 'No calendar available to save the event.';

    final (from, to) = slotFor(day);
    // shortcut: events are stored as UTC instants, so the calendar shows them at the right
    // local time; upgrade to flutter_timezone if the event's own time zone must match the phone's.
    tz.TZDateTime at(int hour) => tz.TZDateTime.from(
      DateTime(day.year, day.month, day.day, hour),
      tz.UTC,
    );

    final published = DateFormat('d MMM yyyy, HH:mm')
        .format(story.createdAt.toLocal());
    final result = await _plugin.createOrUpdateEvent(
      Event(
        calendarId,
        title: story.title,
        description:
            'Author: ${story.author}\nPublished: $published\nLink: ${story.url}',
        url: Uri.parse(story.url),
        start: at(from),
        end: at(to),
      ),
    );
    return result?.isSuccess == true ? null : 'Could not save the event.';
  }

  /// First writable calendar (preferring the default one); creates a local one if the
  /// device has none, e.g. an emulator with no account signed in.
  Future<String?> _writableCalendarId() async {
    final calendars = await _plugin.retrieveCalendars();
    final writable = (calendars.data ?? <Calendar>[])
        .where((c) => c.isReadOnly == false)
        .toList();
    if (writable.isNotEmpty) {
      return (writable.firstWhere(
        (c) => c.isDefault == true,
        orElse: () => writable.first,
      )).id;
    }
    final created = await _plugin.createCalendar(
      'HN Favorites',
      localAccountName: 'HN Reader',
    );
    return created.isSuccess ? created.data : null;
  }
}
