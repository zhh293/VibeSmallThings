import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/core/theme/app_theme.dart';
import 'package:geek_toolbox/features/code_to_video/domain/services/render_service.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/providers/code_to_video_provider.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/widgets/code_editor_widget.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/widgets/preview_player.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/widgets/video_settings_dialog.dart';

class CodeToVideoScreen extends ConsumerStatefulWidget {
  const CodeToVideoScreen({super.key});

  @override
  ConsumerState<CodeToVideoScreen> createState() => _CodeToVideoScreenState();
}

class _CodeToVideoScreenState extends ConsumerState<CodeToVideoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _previewController;
  final GlobalKey _previewKey = GlobalKey();
  bool _isRendering = false;
  double _renderProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previewController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ), // Default, will be updated by config
    );
  }

  Future<void> _startRendering() async {
    if (_isRendering) return;

    setState(() {
      _isRendering = true;
      _renderProgress = 0.0;
    });

    try {
      final config = ref.read(codeToVideoProvider);
      final renderService = RenderService();

      // Pause preview
      _previewController.stop();

      final outputPath = await renderService.renderVideo(
        contentKey: _previewKey,
        controller: _previewController,
        config: config,
        onProgress: (progress) {
          setState(() {
            _renderProgress = progress;
          });
        },
      );

      if (mounted) {
        if (outputPath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Video generated at: $outputPath'),
              action: SnackBarAction(
                label: 'OPEN',
                onPressed: () {
                  // TODO: Open video
                },
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Rendering failed')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRendering = false;
        });
        // Resume or reset preview
        _previewController.repeat(); // Loop preview
      }
    }
  }

  @override
  void dispose() {
    _previewController.dispose();
    super.dispose();
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const VideoSettingsDialog(),
    );
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      ref.read(codeToVideoProvider.notifier).updateCode(data!.text!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CODE-TO-VIDEO'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.black87,
              margin: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: PreviewPlayer(
                      controller: _previewController,
                      contentKey: _previewKey,
                    ),
                  ),
                  if (_isRendering)
                    Container(
                      color: Colors.black54,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'RENDERING... ${(_renderProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.surfaceColor,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.code, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'SOURCE CODE',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _pasteCode,
                          icon: const Icon(Icons.paste, size: 14),
                          label: const Text('PASTE'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(child: CodeEditorWidget()),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isRendering ? null : _startRendering,
                icon: const Icon(Icons.movie_creation),
                label: const Text('GENERATE VIDEO'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
