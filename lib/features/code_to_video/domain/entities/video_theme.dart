import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Defines the visual style of the generated video.
/// Composition over Inheritance.
class VideoTheme extends Equatable {
  final String id;
  final String name;
  final BackgroundLayer background;
  final CodeStyle codeStyle;
  final OverlayEffect? overlay;

  const VideoTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.codeStyle,
    this.overlay,
  });

  static List<VideoTheme> get presets => [
    defaultTheme(),
    const VideoTheme(
      id: 'ocean_breeze',
      name: 'Ocean Breeze',
      background: BackgroundLayer(
        color: Color(0xFF001e3c),
        gradientEndColor: Color(0xFF004e92),
        type: BackgroundType.gradient,
      ),
      codeStyle: CodeStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 24,
        textColor: Color(0xFF00FFFF),
        backgroundColor: Colors.transparent,
      ),
      overlay: OverlayEffect(type: OverlayType.none, intensity: 0.0),
    ),
    const VideoTheme(
      id: 'sunset_vibe',
      name: 'Sunset Vibe',
      background: BackgroundLayer(
        color: Color(0xFF2c3e50),
        gradientEndColor: Color(0xFFfd746c),
        type: BackgroundType.gradient,
      ),
      codeStyle: CodeStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 24,
        textColor: Color(0xFFFFD700),
        backgroundColor: Colors.transparent,
      ),
      overlay: OverlayEffect(type: OverlayType.particles, intensity: 0.2),
    ),
  ];

  static VideoTheme defaultTheme() {
    return const VideoTheme(
      id: 'hacker_default',
      name: 'Matrix Core',
      background: BackgroundLayer(
        color: Color(0xFF000000),
        type: BackgroundType.solid,
      ),
      codeStyle: CodeStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 24,
        textColor: Color(0xFF00FF00),
        backgroundColor: Colors.transparent,
      ),
      overlay: OverlayEffect(type: OverlayType.scanline, intensity: 0.1),
    );
  }

  @override
  List<Object?> get props => [id, name, background, codeStyle, overlay];
}

enum BackgroundType { solid, gradient, image }

class BackgroundLayer extends Equatable {
  final Color color;
  final Color? gradientEndColor;
  final String? assetPath;
  final BackgroundType type;

  const BackgroundLayer({
    required this.color,
    this.gradientEndColor,
    this.assetPath,
    required this.type,
  });

  @override
  List<Object?> get props => [color, gradientEndColor, assetPath, type];
}

class CodeStyle extends Equatable {
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final Color backgroundColor;

  const CodeStyle({
    required this.fontFamily,
    required this.fontSize,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  List<Object?> get props => [fontFamily, fontSize, textColor, backgroundColor];
}

enum OverlayType { none, scanline, particles, glitch }

class OverlayEffect extends Equatable {
  final OverlayType type;
  final double intensity;

  const OverlayEffect({required this.type, required this.intensity});

  @override
  List<Object?> get props => [type, intensity];
}
