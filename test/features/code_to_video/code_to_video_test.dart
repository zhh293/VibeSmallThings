import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_theme.dart';
import 'package:geek_toolbox/features/code_to_video/presentation/providers/code_to_video_provider.dart';

void main() {
  group('CodeToVideoNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should match default theme', () {
      final state = container.read(codeToVideoProvider);
      expect(state.codeContent, '');
      expect(state.theme.id, 'hacker_default');
      expect(state.duration, 10.0);
    });

    test('updateCode should update code content', () {
      final notifier = container.read(codeToVideoProvider.notifier);
      notifier.updateCode('void main() {}');
      
      final state = container.read(codeToVideoProvider);
      expect(state.codeContent, 'void main() {}');
    });

    test('updateSettings should update configuration', () {
      final notifier = container.read(codeToVideoProvider.notifier);
      notifier.updateSettings(duration: 20.0, fps: 30);
      
      final state = container.read(codeToVideoProvider);
      expect(state.duration, 20.0);
      expect(state.fps, 30);
    });

    test('updateTheme should change theme', () {
      final notifier = container.read(codeToVideoProvider.notifier);
      final newTheme = VideoTheme.presets.firstWhere((t) => t.id == 'ocean_breeze');
      
      notifier.updateTheme(newTheme);
      
      final state = container.read(codeToVideoProvider);
      expect(state.theme.id, 'ocean_breeze');
    });
  });
}
