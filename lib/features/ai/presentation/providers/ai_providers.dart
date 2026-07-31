import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nukkad/features/ai/data/services/fallback_local_ai_service.dart';
import 'package:nukkad/features/ai/domain/services/local_ai_service.dart';

/// Provider for Local AI Service abstraction.
/// Swapping to another local AI model (e.g. ExecuTorch) only requires changing this provider binding.
final localAiServiceProvider = Provider<LocalAiService>((ref) {
  return FallbackLocalAiService();
});
