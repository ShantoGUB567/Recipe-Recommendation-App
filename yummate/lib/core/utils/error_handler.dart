import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ErrorHandler {
  static void handleError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    bool showSnackBar = true,
  }) {
    final errorMessage = customMessage ?? _parseError(error);

    if (kDebugMode) {
      debugPrint('Error: $error');
    }

    if (showSnackBar && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static void showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  static String _parseError(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString();

    // Firebase errors
    if (errorString.contains('firebase')) {
      if (errorString.contains('permission')) {
        return 'Permission denied. Please check your credentials.';
      }
      if (errorString.contains('network')) {
        return 'Network error. Please check your connection.';
      }
      return 'Database error. Please try again.';
    }

    // Network errors
    if (errorString.contains('SocketException') ||
        errorString.contains('network')) {
      return 'No internet connection. Please check your network.';
    }

    // Timeout errors
    if (errorString.contains('timeout') ||
        errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }

    // API errors
    if (errorString.contains('API') || errorString.contains('api')) {
      return 'Service unavailable. Please try again later.';
    }

    // Default
    return 'Something went wrong. Please try again.';
  }
}
