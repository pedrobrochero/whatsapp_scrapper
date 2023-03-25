import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart';

void main() async {
  var filePath = join(Directory.current.path, 'assets', 'data.txt');
  final file = File(filePath);
  Stream<String> lines = file
      .openRead()
      .transform(utf8.decoder) // Decode bytes to UTF-8.
      .transform(LineSplitter()); // Convert stream to individual lines.
  try {
    int counter = 0;
    final linesToRead = 999999;
    var divider = ' - ';
    DateFormat format = DateFormat("M/d/yy h:m a");

    // One list for each day
    final counters = [
      List.filled(8, 0),
      List.filled(8, 0),
      List.filled(8, 0),
      List.filled(8, 0),
      List.filled(8, 0),
      List.filled(8, 0),
      List.filled(8, 0),
    ];

    await for (var line in lines) {
      if (!line.contains(divider) ||
          !line.contains(':') ||
          !line.contains(',') ||
          !line.contains('/')) {
        continue;
      }
      final timestamp = line
          .split(divider)
          .first
          .replaceAll(',', '')
          .replaceAll(' ', ' ')
          .toUpperCase();

      final datetime = format.parse(timestamp);
      switch (datetime.weekday) {
        case DateTime.monday:
          modifyList(datetime, counters[0]);
          break;
        case DateTime.tuesday:
          modifyList(datetime, counters[1]);
          break;
        case DateTime.wednesday:
          modifyList(datetime, counters[2]);
          break;
        case DateTime.thursday:
          modifyList(datetime, counters[3]);
          break;
        case DateTime.friday:
          modifyList(datetime, counters[4]);
          break;
        case DateTime.saturday:
          modifyList(datetime, counters[5]);
          break;
        case DateTime.sunday:
          modifyList(datetime, counters[6]);
          break;
      }
      counter++;
      if (counter > linesToRead) {
        break;
      }
    }

    int max = 0;
    for (var list in counters) {
      for (var counter in list) {
        if (counter > max) {
          max = counter;
        }
      }
    }

    final ratios = counters
        .map((e) => e.map((e) => (e / max).toStringAsFixed(2)))
        .toList();

    print('     0-3   3-6   6-9   9-12  12-15 15-18 18-21 21-24');
    print('Mon ${ratios[0]}');
    print('Tue ${ratios[1]}');
    print('Wed ${ratios[2]}');
    print('Thu ${ratios[3]}');
    print('Fri ${ratios[4]}');
    print('Sat ${ratios[5]}');
    print('Sun ${ratios[6]}');

    print('Valid lines: $counter');
  } catch (e) {
    print('Error: $e');
  }
}

modifyList(DateTime dateTime, List<int> list) {
  if (dateTime.hour < 3) {
    list[0]++;
  } else if (dateTime.hour < 6) {
    list[1]++;
  } else if (dateTime.hour < 9) {
    list[2]++;
  } else if (dateTime.hour < 12) {
    list[3]++;
  } else if (dateTime.hour < 15) {
    list[4]++;
  } else if (dateTime.hour < 18) {
    list[5]++;
  } else if (dateTime.hour < 21) {
    list[6]++;
  } else {
    list[7]++;
  }
}
