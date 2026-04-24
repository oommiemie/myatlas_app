import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import 'measure_animations.dart';

/// Renders a 3D `.glb` model for the "measuring" step. Falls back to the
/// 2D [MeasureAnimation] painter when the model file is missing so the
/// feature still works end-to-end before all 3D assets are authored.
class Measure3DAnimation extends StatefulWidget {
  const Measure3DAnimation({
    super.key,
    required this.kind,
    required this.color,
    this.size = 240,
  });

  final MeasureAnimationKind kind;
  final Color color;
  final double size;

  @override
  State<Measure3DAnimation> createState() => _Measure3DAnimationState();
}

class _Measure3DAnimationState extends State<Measure3DAnimation> {
  final Flutter3DController _controller = Flutter3DController();
  late Future<bool> _assetCheck;

  String get _assetPath {
    switch (widget.kind) {
      case MeasureAnimationKind.ecg:
        return 'assets/3d/ecg.glb';
      case MeasureAnimationKind.pressureCuff:
        return 'assets/3d/pressure_cuff.glb';
      case MeasureAnimationKind.thermometer:
        return 'assets/3d/thermometer.glb';
      case MeasureAnimationKind.sugarDrop:
        return 'assets/3d/sugar_drop.glb';
      case MeasureAnimationKind.pulseOx:
        return 'assets/3d/pulse_ox.glb';
      case MeasureAnimationKind.scale:
        return 'assets/3d/scale.glb';
      case MeasureAnimationKind.tape:
        return 'assets/3d/tape.glb';
      case MeasureAnimationKind.sleep:
        return 'assets/3d/sleep.glb';
    }
  }

  @override
  void initState() {
    super.initState();
    _assetCheck = _hasAsset();
  }

  @override
  void didUpdateWidget(covariant Measure3DAnimation old) {
    super.didUpdateWidget(old);
    if (old.kind != widget.kind) {
      _assetCheck = _hasAsset();
    }
  }

  Future<bool> _hasAsset() async {
    try {
      await rootBundle.load(_assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _fallback() => MeasureAnimation(
        kind: widget.kind,
        color: widget.color,
        size: widget.size,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<bool>(
        future: _assetCheck,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return _fallback();
          }
          if (snap.data != true) {
            return _fallback();
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Flutter3DViewer(
              controller: _controller,
              src: _assetPath,
              progressBarColor: widget.color,
              enableTouch: false,
              activeGestureInterceptor: true,
              onLoad: (_) {
                _controller.playAnimation();
              },
              onError: (_) {},
            ),
          );
        },
      ),
    );
  }
}
