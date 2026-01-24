import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<Duration>> _metrics = {};

  /// Start timing an operation
  static void startTimer(String operationName) {
    if (!kDebugMode) return;

    _timers[operationName] = Stopwatch()..start();
  }

  /// End timing and log results
  static void endTimer(String operationName, {bool logResult = true}) {
    if (!kDebugMode) return;

    final timer = _timers[operationName];
    if (timer == null) {
      debugPrint('⚠️ Timer not found for: $operationName');
      return;
    }

    timer.stop();
    final duration = timer.elapsed;

    // Store metric
    _metrics.putIfAbsent(operationName, () => []).add(duration);

    if (logResult) {
      debugPrint('⏱️ $operationName: ${duration.inMilliseconds}ms');
    }

    _timers.remove(operationName);
  }

  /// Execute and time a function
  static Future<T> timeAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      final result = await operation();
      endTimer(operationName);
      return result;
    } catch (e) {
      endTimer(operationName, logResult: false);
      debugPrint('❌ Error in $operationName: $e');
      rethrow;
    }
  }

  /// Execute and time a synchronous function
  static T timeSync<T>(String operationName, T Function() operation) {
    startTimer(operationName);
    try {
      final result = operation();
      endTimer(operationName);
      return result;
    } catch (e) {
      endTimer(operationName, logResult: false);
      debugPrint('❌ Error in $operationName: $e');
      rethrow;
    }
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    final totalMs = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Print performance summary
  static void printSummary() {
    if (!kDebugMode) return;

    debugPrint('\n📊 Performance Summary:');
    debugPrint('=' * 50);

    for (final entry in _metrics.entries) {
      final avg = getAverageDuration(entry.key);
      final count = entry.value.length;

      debugPrint('${entry.key}:');
      debugPrint('  Count: $count');
      debugPrint('  Average: ${avg?.inMilliseconds}ms');
    }

    debugPrint('=' * 50);
  }

  /// Clear all metrics
  static void clear() {
    _timers.clear();
    _metrics.clear();
  }
}
