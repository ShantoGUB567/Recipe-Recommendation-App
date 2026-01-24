import 'dart:async';
import 'package:flutter/foundation.dart';

class NetworkHelper {
  /// Executes an async operation with retry logic
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool exponentialBackoff = true,
  }) async {
    int attempt = 0;
    Duration currentDelay = retryDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          rethrow;
        }

        if (kDebugMode) {
          debugPrint('Retry attempt $attempt/$maxRetries after error: $e');
        }

        await Future.delayed(currentDelay);

        if (exponentialBackoff) {
          currentDelay *= 2;
        }
      }
    }
  }

  /// Executes operation with timeout
  static Future<T> executeWithTimeout<T>({
    required Future<T> Function() operation,
    Duration timeout = const Duration(seconds: 30),
    String? timeoutMessage,
  }) async {
    try {
      return await operation().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            timeoutMessage ??
                'Operation timed out after ${timeout.inSeconds} seconds',
          );
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Combines retry and timeout
  static Future<T> executeResilient<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration timeout = const Duration(seconds: 30),
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    return executeWithRetry(
      operation: () =>
          executeWithTimeout(operation: operation, timeout: timeout),
      maxRetries: maxRetries,
      retryDelay: retryDelay,
    );
  }

  /// Checks if error is network-related
  static bool isNetworkError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('unreachable');
  }

  /// Checks if error should trigger retry
  static bool shouldRetry(dynamic error) {
    if (isNetworkError(error)) return true;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('timeout') ||
        errorString.contains('503') ||
        errorString.contains('502') ||
        errorString.contains('504');
  }
}
