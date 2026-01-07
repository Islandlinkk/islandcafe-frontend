import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_cafe/feature/auth/services/auth_service.dart';
import 'package:island_cafe/feature/history/data/model/feedback_model.dart';
import 'package:island_cafe/feature/history/service/feedback_service.dart';

final feedbackProvider = FutureProvider.autoDispose<List<FeedbackModel>>((ref) async {
  final user = AuthService.currentUser;
  if (user != null) {
    return await FeedbackService.fetchMyFeedback();
  } else {
    return await FeedbackService.fetchFeedback();
  }
});