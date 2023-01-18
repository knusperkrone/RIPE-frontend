import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformAssetImage implements ImageProvider {
  late ImageProvider delegate;

  PlatformAssetImage(String path) {
    if (kIsWeb) {
      delegate = NetworkImage(path);
    } else {
      delegate = FileImage(File(path));
    }
  }

  @override
  ImageStream createStream(ImageConfiguration configuration) =>
      delegate.createStream(configuration);

  @override
  Future<bool> evict({ImageCache? cache,
    ImageConfiguration configuration = ImageConfiguration.empty}) =>
      delegate.evict(cache: cache, configuration: configuration);

  @override
  ImageStreamCompleter load(Object key, DecoderCallback decode) =>
      delegate.load(key, decode);

  @override
  ImageStreamCompleter loadBuffer(Object key, DecoderBufferCallback decode) =>
      loadBuffer(key, decode);

  @override
  Future<ImageCacheStatus?> obtainCacheStatus(
      {required ImageConfiguration configuration,
        ImageErrorListener? handleError}) =>
      delegate.obtainCacheStatus(
          configuration: configuration, handleError: handleError);

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) =>
      delegate.obtainKey(configuration);

  @override
  ImageStream resolve(ImageConfiguration configuration) =>
      resolve(configuration);

  @override
  void resolveStreamForKey(ImageConfiguration configuration, ImageStream stream,
      Object key, ImageErrorListener handleError) =>
      delegate.resolveStreamForKey(configuration, stream, key, handleError);
}
