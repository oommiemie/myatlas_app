import 'package:flutter/foundation.dart';

class ProfilePhotoService {
  ProfilePhotoService._();
  static final ProfilePhotoService instance = ProfilePhotoService._();

  /// Path to the currently selected photo file.
  /// `null` means fall back to the default asset.
  final ValueNotifier<String?> path = ValueNotifier<String?>(null);

  void set(String newPath) => path.value = newPath;
  void clear() => path.value = null;
}
