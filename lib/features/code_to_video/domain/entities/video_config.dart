import 'package:equatable/equatable.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';

class VideoConfig extends Equatable {
  final String codeContent;
  final String language;
  final VideoTheme theme;
  final double duration; // In seconds
  final int fps;
  final bool autoTyping;
  final double typingSpeed; // Characters per second

  const VideoConfig({
    this.codeContent = '',
    this.language = 'dart',
    required this.theme,
    this.duration = 10.0,
    this.fps = 60,
    this.autoTyping = true,
    this.typingSpeed = 20.0,
  });

  VideoConfig copyWith({
    String? codeContent,
    String? language,
    VideoTheme? theme,
    double? duration,
    int? fps,
    bool? autoTyping,
    double? typingSpeed,
  }) {
    return VideoConfig(
      codeContent: codeContent ?? this.codeContent,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      duration: duration ?? this.duration,
      fps: fps ?? this.fps,
      autoTyping: autoTyping ?? this.autoTyping,
      typingSpeed: typingSpeed ?? this.typingSpeed,
    );
  }

  @override
  List<Object?> get props => [codeContent, language, theme, duration, fps, autoTyping, typingSpeed];
}
