import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/providers/code_to_video_provider.dart';

class CodeEditorWidget extends ConsumerStatefulWidget {
  const CodeEditorWidget({super.key});

  @override
  ConsumerState<CodeEditorWidget> createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends ConsumerState<CodeEditorWidget> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    // Initialize with current state
    final currentCode = ref.read(codeToVideoProvider).codeContent;
    _codeController = CodeController(
      text: currentCode,
      language: dart,
    );

    _codeController.addListener(() {
      ref.read(codeToVideoProvider.notifier).updateCode(_codeController.text);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for external changes (e.g. Paste)
    ref.listen(codeToVideoProvider.select((s) => s.codeContent), (
      previous,
      next,
    ) {
      if (next != _codeController.text) {
        _codeController.text = next;
      }
    });

    return CodeTheme(
      data: CodeThemeData(styles: monokaiSublimeTheme),
      child: CodeField(
        controller: _codeController,
        textStyle: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 14),
        expands: true,
        wrap: false,
      ),
    );
  }
}
