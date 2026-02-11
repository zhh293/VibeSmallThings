import 'package:flutter/material.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';

class ThemeMapper {
  static Map<String, TextStyle> map(VideoTheme theme) {
    // Start with a base theme
    Map<String, TextStyle> base;
    
    // Simple heuristic or mapping based on ID
    if (theme.id == 'ocean_breeze') {
      base = Map.from(githubTheme);
    } else if (theme.id == 'sunset_vibe') {
      base = Map.from(draculaTheme);
    } else {
      base = Map.from(monokaiSublimeTheme);
    }

    // Override root style to match our VideoTheme configuration
    // Note: HighlightView might ignore some root properties if not handled carefully,
    // but usually 'root' key controls the container style.
    // However, in our PreviewPlayer, we control the container background separately.
    // So we primarily care about the text color.
    
    final rootStyle = base['root'] ?? const TextStyle();
    base['root'] = rootStyle.copyWith(
      color: theme.codeStyle.textColor,
      backgroundColor: Colors.transparent, // We handle background in PreviewPlayer
      fontFamily: theme.codeStyle.fontFamily,
      fontSize: theme.codeStyle.fontSize,
    );

    return base;
  }
}
