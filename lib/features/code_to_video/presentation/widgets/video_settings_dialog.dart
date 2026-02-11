import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/providers/code_to_video_provider.dart';

class VideoSettingsDialog extends ConsumerWidget {
  const VideoSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(codeToVideoProvider);
    final notifier = ref.read(codeToVideoProvider.notifier);

    return AlertDialog(
      title: const Text('VIDEO SETTINGS'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration
            const Text('DURATION', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: config.duration,
                    min: 5.0,
                    max: 60.0,
                    divisions: 11,
                    label: '${config.duration.toInt()}s',
                    activeColor: AppTheme.primaryColor,
                    onChanged: (value) {
                      notifier.updateSettings(duration: value);
                    },
                  ),
                ),
                Text('${config.duration.toInt()}s'),
              ],
            ),
            const SizedBox(height: 16),

            // FPS
            const Text('FRAMERATE', style: TextStyle(color: Colors.grey, fontSize: 12)),
            DropdownButton<int>(
              value: config.fps,
              isExpanded: true,
              dropdownColor: AppTheme.surfaceColor,
              items: const [30, 60].map((fps) {
                return DropdownMenuItem(
                  value: fps,
                  child: Text('$fps FPS'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.updateSettings(fps: value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Theme
            const Text('THEME', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: VideoTheme.presets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final theme = VideoTheme.presets[index];
                  final isSelected = theme.id == config.theme.id;
                  
                  return GestureDetector(
                    onTap: () {
                      notifier.updateTheme(theme);
                    },
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: theme.background.color,
                        gradient: theme.background.type == BackgroundType.gradient
                            ? LinearGradient(
                                colors: [
                                  theme.background.color,
                                  theme.background.gradientEndColor!,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          theme.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.codeStyle.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }
}
