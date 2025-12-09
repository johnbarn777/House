import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LlmService {
  final FirebaseFunctions _functions;

  LlmService({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  /// Calls the Cloud Function to auto-schedule a chore based on user's schedule.
  /// Returns the calculated next due date, or null if the function fails.
  Future<DateTime?> autoScheduleChore({
    required String choreTitle,
    required String frequency,
    required int count,
  }) async {
    try {
      final result = await _functions.httpsCallable('autoScheduleChore').call({
        'choreTitle': choreTitle,
        'frequency': frequency,
        'count': count,
      });

      final data = result.data as Map<String, dynamic>;
      final nextDueAtString = data['nextDueAt'] as String?;

      if (nextDueAtString != null) {
        return DateTime.parse(nextDueAtString);
      }
      return null;
    } catch (e) {
      // Log error but don't throw - caller will handle null gracefully
      print('LlmService.autoScheduleChore error: $e');
      return null;
    }
  }
}

final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmService();
});
