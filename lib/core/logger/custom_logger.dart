// ignore_for_file: avoid_print

import 'dart:io';

import 'package:loggy/loggy.dart';

class ConsolePrinter extends LoggyPrinter {
  const ConsolePrinter({this.showColors = false});

  final bool showColors;

  static final _levelColors = {
    LogLevel.debug: AnsiColor(foregroundColor: AnsiColor.grey(0.5), italic: true),
    LogLevel.info: AnsiColor(foregroundColor: 35),
    LogLevel.warning: AnsiColor(foregroundColor: 214),
    LogLevel.error: AnsiColor(foregroundColor: 196),
  };

  @override
  void onLog(LogRecord record) {
    final colorize = showColors && stdout.supportsAnsiEscapes;
    final time = record.time.toIso8601String().split('T')[1];
    final callerFrame = record.callerFrame == null ? ' ' : ' (${record.callerFrame?.location}) ';

    final String logLevel;
    if (colorize) {
      logLevel = record.level.name.toUpperCase().padRight(8);
    } else {
      logLevel = "[${record.level.name.toUpperCase()}]".padRight(10);
    }

    final color = showColors ? levelColor(record.level) ?? AnsiColor() : AnsiColor();

    print(color('$time $logLevel [${record.loggerName}]$callerFrame${record.message}'));

    if (record.stackTrace != null) {
      print(record.stackTrace);
    }
  }

  AnsiColor? levelColor(LogLevel level) {
    return _levelColors[level];
  }
}

class FileLogPrinter extends LoggyPrinter {
  FileLogPrinter(String filePath, {this.minLevel = LogLevel.debug}) : _logFile = File(filePath);

  final File _logFile;
  final LogLevel minLevel;

  IOSink? _sink;
  bool _disposed = false;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final parent = _logFile.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }
      _sink = _logFile.openWrite(mode: FileMode.append);
    } catch (e) {
      _sink = null;
    }
  }

  @override
  void onLog(LogRecord record) {
    if (_disposed) return;
    _init().then((_) {
      if (_disposed || _sink == null) return;
      try {
        final time = record.time.toIso8601String().split('T')[1];
        _sink!.writeln("$time - $record");
        if (record.error != null) {
          _sink!.writeln(record.error);
        }
        if (record.stackTrace != null) {
          _sink!.writeln(record.stackTrace);
        }
      } catch (_) {}
    });
  }

  void dispose() {
    _disposed = true;
    try {
      _sink?.close();
    } catch (_) {}
  }
}
