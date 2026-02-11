import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_config.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/providers/code_to_video_provider.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:geek_toolbox/features/code_to_video/domain/utils/theme_mapper.dart';

class PreviewPlayer extends ConsumerWidget {
  final AnimationController?
  controller; // If provided, controls the animation manually
  final GlobalKey? contentKey; // Key for RepaintBoundary

  const PreviewPlayer({super.key, this.controller, this.contentKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(codeToVideoProvider);

    return RepaintBoundary(
      key: contentKey,
      child: Container(
        color: config.theme.background.color,
        child: Stack(
          children: [
            // Background Layer
            if (config.theme.background.type == BackgroundType.gradient)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      config.theme.background.color,
                      config.theme.background.gradientEndColor ?? Colors.black,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

            // Code Layer
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: _AnimatedCodeText(
                    code: config.codeContent,
                    theme: config.theme,
                    duration: config.duration,
                    controller: controller,
                  ),
                ),
              ),
            ),

            // Overlay Layer
            if (config.theme.overlay != null &&
                config.theme.overlay!.type != OverlayType.none)
              _OverlayLayer(effect: config.theme.overlay!),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCodeText extends StatefulWidget {
  final String code;
  final VideoTheme theme;
  final double duration;
  final AnimationController? controller;

  const _AnimatedCodeText({
    required this.code,
    required this.theme,
    required this.duration,
    this.controller,
  });

  @override
  State<_AnimatedCodeText> createState() => _AnimatedCodeTextState();
}

class _AnimatedCodeTextState extends State<_AnimatedCodeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _localController;
  late Animation<int> _textAnimation;

  @override
  void initState() {
    super.initState();
    _localController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.duration * 1000).toInt()),
    );
    _updateAnimation();

    if (widget.controller == null) {
      _localController.forward();
    }
  }

  @override
  void didUpdateWidget(_AnimatedCodeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.code != oldWidget.code ||
        widget.duration != oldWidget.duration) {
      _localController.duration = Duration(
        milliseconds: (widget.duration * 1000).toInt(),
      );
      _updateAnimation();
      if (widget.controller == null) {
        _localController.reset();
        _localController.forward();
      }
    }
  }

  void _updateAnimation() {
    _textAnimation = IntTween(
      begin: 0,
      end: widget.code.length,
    ).animate(widget.controller ?? _localController);
  }

  @override
  void dispose() {
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine which controller to listen to for rebuilds
    final listenable = widget.controller ?? _localController;

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, child) {
        final count = _textAnimation.value;
        final currentText = widget.code.length >= count
            ? widget.code.substring(0, count)
            : widget.code;

        return HighlightView(
          currentText,
          language: 'dart', // TODO: Make dynamic
          theme: ThemeMapper.map(widget.theme),
          padding: const EdgeInsets.all(12),
          textStyle: TextStyle(
            fontFamily: widget.theme.codeStyle.fontFamily,
            fontSize: widget.theme.codeStyle.fontSize,
            color: widget.theme.codeStyle.textColor,
          ),
        );
      },
    );
  }
}

class _OverlayLayer extends StatelessWidget {
  final OverlayEffect effect;

  const _OverlayLayer({required this.effect});

  @override
  Widget build(BuildContext context) {
    // Simple implementation for now
    if (effect.type == OverlayType.scanline) {
      return IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(effect.intensity),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
              tileMode: TileMode.repeated,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
