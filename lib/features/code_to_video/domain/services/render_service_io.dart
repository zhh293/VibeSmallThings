import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_config.dart';

class RenderService {
  Future<String?> renderVideo({
    required GlobalKey contentKey,
    required AnimationController controller,
    required VideoConfig config,
    required Function(double progress) onProgress,
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String framesDir = '${tempDir.path}/frames_${DateTime.now().millisecondsSinceEpoch}';
      await Directory(framesDir).create();

      final int totalFrames = (config.duration * config.fps).toInt();
      
      // 1. Generate Frames
      for (int i = 0; i < totalFrames; i++) {
        final double progress = i / totalFrames;
        
        // Update Animation
        controller.value = progress;
        
        // Wait for frame to be painted
        // We use a short delay to ensure the widget tree has updated. 
        // In a perfect world, we'd use SchedulerBinding, but in this context 
        // we are manually driving the controller.
        await Future.delayed(const Duration(milliseconds: 16)); 

        // Capture Frame
        final Uint8List? imageBytes = await _captureFrame(contentKey);
        if (imageBytes != null) {
          final String framePath = '$framesDir/frame_${i.toString().padLeft(5, '0')}.png';
          await File(framePath).writeAsBytes(imageBytes);
        }

        onProgress(0.5 * progress); // First 50% is generation
      }

      // 2. Encode Video using FFmpeg
      final String outputPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String ffmpegCommand = 
          '-framerate ${config.fps} -i "$framesDir/frame_%05d.png" -c:v libx264 -pix_fmt yuv420p "$outputPath"';

      final session = await FFmpegKit.execute(ffmpegCommand);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress(1.0);
        // Clean up frames
        await Directory(framesDir).delete(recursive: true);
        return outputPath;
      } else {
        print('FFmpeg Error: ${await session.getAllLogsAsString()}');
        return null;
      }
    } catch (e) {
      print('Render Error: $e');
      return null;
    }
  }

  Future<Uint8List?> _captureFrame(GlobalKey key) async {
    try {
      final RenderRepaintBoundary? boundary = 
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) return null;

      // Capture at 2.0 pixel ratio for better quality (1080p-ish if base is big enough)
      // Or we can calculate exact pixel ratio to match 1080p.
      // For now, let's stick to screen resolution * 2 for high quality.
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Capture Error: $e');
      return null;
    }
  }
}
