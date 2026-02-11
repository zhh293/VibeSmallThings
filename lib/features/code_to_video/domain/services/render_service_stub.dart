import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geek_toolbox/features/code_to_video/domain/entities/video_config.dart';

class RenderService {
  Future<String?> renderVideo({
    required GlobalKey contentKey,
    required AnimationController controller,
    required VideoConfig config,
    required Function(double progress) onProgress,
  }) async {
    throw UnsupportedError('Platform not supported');
  }
}
