import 'dart:io';

import 'package:flutter/services.dart';

/// Bridge to iOS ActivityKit — starts / updates / ends the hospital-queue
/// Live Activity on the Lock Screen and Dynamic Island.
///
/// No-op on non-iOS platforms and on iOS < 16.1.
class LiveActivityService {
  LiveActivityService._();
  static final instance = LiveActivityService._();

  static const MethodChannel _channel =
      MethodChannel('myatlas/live_activity');

  Future<bool> isSupported() async {
    if (!Platform.isIOS) return false;
    try {
      final v = await _channel.invokeMethod<bool>('isSupported');
      return v ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> start({
    required String hospitalName,
    required String queueCode,
    required String servicePoint,
    required int waitCount,
    required String etaLabel,
    required int step,
    required String statusLabel,
  }) async {
    if (!Platform.isIOS) return null;
    try {
      final id = await _channel.invokeMethod<String>('start', {
        'hospitalName': hospitalName,
        'queueCode': queueCode,
        'servicePoint': servicePoint,
        'waitCount': waitCount,
        'etaLabel': etaLabel,
        'step': step,
        'statusLabel': statusLabel,
      });
      // ignore: avoid_print
      print('[LiveActivity] start → id=$id');
      return id;
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('[LiveActivity] start FAILED: ${e.code} — ${e.message}');
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[LiveActivity] start EXCEPTION: $e');
      return null;
    }
  }

  Future<bool> update({
    required int waitCount,
    required String etaLabel,
    required int step,
    required String statusLabel,
  }) async {
    if (!Platform.isIOS) return false;
    try {
      final v = await _channel.invokeMethod<bool>('update', {
        'waitCount': waitCount,
        'etaLabel': etaLabel,
        'step': step,
        'statusLabel': statusLabel,
      });
      return v ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> end() async {
    if (!Platform.isIOS) return false;
    try {
      final v = await _channel.invokeMethod<bool>('end');
      return v ?? false;
    } catch (_) {
      return false;
    }
  }
}
