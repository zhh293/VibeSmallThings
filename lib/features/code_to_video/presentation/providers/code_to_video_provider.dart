import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_config.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';

class CodeToVideoNotifier extends StateNotifier<VideoConfig> {
  CodeToVideoNotifier()
      : super(VideoConfig(theme: VideoTheme.defaultTheme()));

  void updateCode(String code) {
    state = state.copyWith(codeContent: code);
  }

  void updateTheme(VideoTheme theme) {
    state = state.copyWith(theme: theme);
  }

  void updateSettings({double? duration, int? fps, bool? autoTyping, double? typingSpeed}) {
    state = state.copyWith(
      duration: duration,
      fps: fps,
      autoTyping: autoTyping,
      typingSpeed: typingSpeed,
    );
  }
}

final codeToVideoProvider = StateNotifierProvider<CodeToVideoNotifier, VideoConfig>((ref) {
  return CodeToVideoNotifier();
});
