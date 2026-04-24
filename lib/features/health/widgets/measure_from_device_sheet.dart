import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import 'add_vital_sign_sheet.dart' show VitalFieldConfig, VitalMeasurement;
import 'measure_3d_animation.dart';
import 'measure_animations.dart';

enum _DeviceStage { searching, connecting, measuring, done }

enum _StatusLevel { normal, warn, alert }

class _StatusInfo {
  const _StatusInfo({required this.level, required this.label});
  final _StatusLevel level;
  final String label;

  Color get color {
    switch (level) {
      case _StatusLevel.normal:
        return const Color(0xFF1D8B6B);
      case _StatusLevel.warn:
        return const Color(0xFFD97706);
      case _StatusLevel.alert:
        return const Color(0xFFDC2626);
    }
  }

  IconData get icon {
    switch (level) {
      case _StatusLevel.normal:
        return CupertinoIcons.checkmark_seal_fill;
      case _StatusLevel.warn:
        return CupertinoIcons.exclamationmark_triangle_fill;
      case _StatusLevel.alert:
        return CupertinoIcons.exclamationmark_octagon_fill;
    }
  }
}

/// Evaluate whether measured values fall within normal reference ranges.
/// Returns `null` when values can't be parsed — in which case the UI
/// simply omits the status badge rather than guessing.
_StatusInfo? _evaluateStatus(
  MeasureAnimationKind kind,
  List<String> values,
) {
  double? parse(int i) {
    if (i >= values.length) return null;
    return double.tryParse(values[i]);
  }

  switch (kind) {
    case MeasureAnimationKind.ecg:
      final bpm = parse(0);
      if (bpm == null) return null;
      if (bpm < 60) return const _StatusInfo(level: _StatusLevel.warn, label: 'ชีพจรต่ำ');
      if (bpm > 100) return const _StatusInfo(level: _StatusLevel.warn, label: 'ชีพจรเร็ว');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.pressureCuff:
      final sys = parse(0);
      final dia = parse(1);
      if (sys == null || dia == null) return null;
      if (sys >= 140 || dia >= 90) {
        return const _StatusInfo(level: _StatusLevel.alert, label: 'ความดันสูง');
      }
      if (sys >= 130 || dia >= 80) {
        return const _StatusInfo(level: _StatusLevel.warn, label: 'ค่อนข้างสูง');
      }
      if (sys < 90 || dia < 60) {
        return const _StatusInfo(level: _StatusLevel.warn, label: 'ความดันต่ำ');
      }
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.thermometer:
      final t = parse(0);
      if (t == null) return null;
      if (t >= 38.0) return const _StatusInfo(level: _StatusLevel.alert, label: 'ไข้สูง');
      if (t >= 37.3) return const _StatusInfo(level: _StatusLevel.warn, label: 'อุณหภูมิสูงเล็กน้อย');
      if (t < 36.1) return const _StatusInfo(level: _StatusLevel.warn, label: 'อุณหภูมิต่ำ');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.sugarDrop:
      final s = parse(0);
      if (s == null) return null;
      if (s < 70) return const _StatusInfo(level: _StatusLevel.warn, label: 'น้ำตาลต่ำ');
      if (s >= 200) return const _StatusInfo(level: _StatusLevel.alert, label: 'น้ำตาลสูงมาก');
      if (s >= 140) return const _StatusInfo(level: _StatusLevel.warn, label: 'น้ำตาลสูง');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.pulseOx:
      final s = parse(0);
      if (s == null) return null;
      if (s < 90) return const _StatusInfo(level: _StatusLevel.alert, label: 'ออกซิเจนต่ำ');
      if (s < 95) return const _StatusInfo(level: _StatusLevel.warn, label: 'ต่ำกว่าปกติ');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.scale:
      // BMI calc: values[0] = weight (kg), values[1] = height (cm)
      final w = parse(0);
      final hCm = parse(1);
      if (w == null || hCm == null || hCm <= 0) return null;
      final h = hCm / 100;
      final bmi = w / (h * h);
      final bmiStr = bmi.toStringAsFixed(1);
      if (bmi < 18.5) {
        return _StatusInfo(level: _StatusLevel.warn, label: 'น้ำหนักน้อย · BMI $bmiStr');
      }
      if (bmi >= 30) {
        return _StatusInfo(level: _StatusLevel.alert, label: 'อ้วน · BMI $bmiStr');
      }
      if (bmi >= 25) {
        return _StatusInfo(level: _StatusLevel.warn, label: 'น้ำหนักเกิน · BMI $bmiStr');
      }
      return _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ · BMI $bmiStr');

    case MeasureAnimationKind.tape:
      final w = parse(0);
      if (w == null) return null;
      if (w >= 90) return const _StatusInfo(level: _StatusLevel.warn, label: 'รอบเอวเกินเกณฑ์');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');

    case MeasureAnimationKind.sleep:
      final h = parse(0);
      if (h == null) return null;
      if (h < 6) return const _StatusInfo(level: _StatusLevel.warn, label: 'นอนน้อย');
      if (h > 9) return const _StatusInfo(level: _StatusLevel.warn, label: 'นอนมากเกินไป');
      return const _StatusInfo(level: _StatusLevel.normal, label: 'ปกติ');
  }
}

class MockDevice {
  const MockDevice({required this.name, required this.model});
  final String name;
  final String model;
}

/// Shows a separate flow for measuring a vital via a paired device.
/// Simulates: searching → connecting → measuring (progress) → result.
Future<VitalMeasurement?> showMeasureFromDeviceSheet(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required List<VitalFieldConfig> fields,
  required MeasureAnimationKind animation,
  List<MockDevice>? devices,
}) {
  return Navigator.of(context, rootNavigator: true).push<VitalMeasurement>(
    PageRouteBuilder<VitalMeasurement>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: 'measure-device',
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, _, __) => _MeasureFromDeviceSheet(
        title: title,
        icon: icon,
        color: color,
        fields: fields,
        animation: animation,
        devices: devices ??
            const [
              MockDevice(name: 'Omron HEM-7280T', model: 'BLE · 92%'),
              MockDevice(name: 'iHealth Track', model: 'BLE · 78%'),
              MockDevice(name: 'Xiaomi Mi BP', model: 'BLE · 54%'),
            ],
      ),
      transitionsBuilder: (ctx, anim, sec, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    ),
  );
}

class _MeasureFromDeviceSheet extends StatefulWidget {
  const _MeasureFromDeviceSheet({
    required this.title,
    required this.icon,
    required this.color,
    required this.fields,
    required this.animation,
    required this.devices,
  });
  final String title;
  final IconData icon;
  final Color color;
  final List<VitalFieldConfig> fields;
  final MeasureAnimationKind animation;
  final List<MockDevice> devices;

  @override
  State<_MeasureFromDeviceSheet> createState() =>
      _MeasureFromDeviceSheetState();
}

class _MeasureFromDeviceSheetState extends State<_MeasureFromDeviceSheet>
    with TickerProviderStateMixin {
  _DeviceStage _stage = _DeviceStage.searching;
  MockDevice? _selected;
  double _progress = 0;
  Timer? _progressTimer;
  List<String> _values = [];
  DateTime? _measuredAt;
  _StatusInfo? _status;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _pickDevice(MockDevice d) async {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = d;
      _stage = _DeviceStage.connecting;
    });
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    _startMeasure();
  }

  void _startMeasure() {
    HapticFeedback.lightImpact();
    setState(() {
      _stage = _DeviceStage.measuring;
      _progress = 0;
    });
    const total = Duration(milliseconds: 3600);
    final start = DateTime.now();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      final p = (elapsed / total.inMilliseconds).clamp(0.0, 1.0);
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _progress = p);
      if (p >= 1) {
        t.cancel();
        _finishMeasure();
      }
    });
  }

  void _finishMeasure() {
    HapticFeedback.mediumImpact();
    final rng = math.Random();
    final generated = <String>[];
    for (final f in widget.fields) {
      // Generate plausible values based on placeholder
      final base = double.tryParse(f.placeholder) ?? 0;
      final isInt = !f.placeholder.contains('.');
      final variance = base * 0.08;
      final v = base + (rng.nextDouble() * 2 - 1) * variance;
      generated.add(isInt ? v.round().toString() : v.toStringAsFixed(1));
    }
    setState(() {
      _values = generated;
      _measuredAt = DateTime.now();
      _status = _evaluateStatus(widget.animation, generated);
      _stage = _DeviceStage.done;
    });
  }

  void _save() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(
      VitalMeasurement(
        values: _values,
        measuredAt: _measuredAt ?? DateTime.now(),
        location: _selected?.name ?? '',
      ),
    );
  }

  void _rescan() {
    setState(() {
      _selected = null;
      _stage = _DeviceStage.searching;
      _values = [];
      _measuredAt = null;
      _status = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      resizeToAvoidBottomInset: false,
      child: Padding(
        padding: EdgeInsets.only(top: topInset + 10),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(38)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(38)),
                border: Border(
                  top: BorderSide(
                    color: CupertinoColors.white.withValues(alpha: 0.35),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 36,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Align(
                            alignment: _stage == _DeviceStage.done
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          if (_stage == _DeviceStage.done)
                            Align(
                              alignment: Alignment.centerRight,
                              child: LiquidGlassButton(
                                icon: CupertinoIcons.check_mark,
                                iconColor: CupertinoColors.white,
                                tint: const Color(0xFF1D8B6B),
                                onTap: _save,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_stage) {
      case _DeviceStage.searching:
        return _SearchingView(
          color: widget.color,
          icon: widget.icon,
          pulse: _pulse,
          devices: widget.devices,
          onPick: _pickDevice,
        );
      case _DeviceStage.connecting:
        return _ConnectingView(
          color: widget.color,
          icon: widget.icon,
          pulse: _pulse,
          device: _selected!,
        );
      case _DeviceStage.measuring:
        return _MeasuringView(
          color: widget.color,
          animation: widget.animation,
          progress: _progress,
          device: _selected!,
        );
      case _DeviceStage.done:
        return _ResultView(
          color: widget.color,
          icon: widget.icon,
          fields: widget.fields,
          values: _values,
          measuredAt: _measuredAt ?? DateTime.now(),
          status: _status,
          device: _selected!,
          onRescan: _rescan,
        );
    }
  }
}

// ─── Searching: pulse ring + list of devices ─────────────────────────────

class _SearchingView extends StatelessWidget {
  const _SearchingView({
    required this.color,
    required this.icon,
    required this.pulse,
    required this.devices,
    required this.onPick,
  });
  final Color color;
  final IconData icon;
  final Animation<double> pulse;
  final List<MockDevice> devices;
  final ValueChanged<MockDevice> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Center(
          child: _PulseRing(
            controller: pulse,
            color: const Color(0xFF0A84FF),
            icon: CupertinoIcons.bluetooth,
          ),
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            'กำลังค้นหาอุปกรณ์',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'เลือกอุปกรณ์ที่ต้องการเชื่อมต่อ',
            style: TextStyle(
              color: const Color(0xFF6D756E),
              fontSize: 13,
              letterSpacing: 0.2,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: CupertinoColors.white,
            child: Column(
              children: [
                for (int i = 0; i < devices.length; i++) ...[
                  PressEffect(
                    onTap: () => onPick(devices[i]),
                    haptic: HapticKind.none,
                    scale: 0.99,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                      color: CupertinoColors.white,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withValues(alpha: 0.12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              CupertinoIcons.bluetooth,
                              size: 15,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  devices[i].name,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  devices[i].model,
                                  style: const TextStyle(
                                    color: Color(0xFF6D756E),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            CupertinoIcons.chevron_right,
                            size: 14,
                            color:
                                const Color(0xFF1A1A1A).withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i != devices.length - 1)
                    Container(
                      margin: const EdgeInsets.only(left: 60),
                      height: 0.5,
                      color: const Color(0xFFEDEDF0),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Connecting: pulse + device name ─────────────────────────────────────

class _ConnectingView extends StatelessWidget {
  const _ConnectingView({
    required this.color,
    required this.icon,
    required this.pulse,
    required this.device,
  });
  final Color color;
  final IconData icon;
  final Animation<double> pulse;
  final MockDevice device;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PulseRing(controller: pulse, color: color, icon: icon),
        const SizedBox(height: 24),
        const Text(
          'กำลังเชื่อมต่อ...',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          device.name,
          style: const TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Measuring: pulsing icon + linear progress ───────────────────────────

class _MeasuringView extends StatelessWidget {
  const _MeasuringView({
    required this.color,
    required this.animation,
    required this.progress,
    required this.device,
  });
  final Color color;
  final MeasureAnimationKind animation;
  // kept for API compatibility with parent; not rendered
  final double progress;
  final MockDevice device;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Measure3DAnimation(kind: animation, color: color, size: 260),
          const SizedBox(height: 28),
          const Text(
            'กำลังวัดค่า',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'โปรดอยู่นิ่งจนกว่าการวัดจะเสร็จ',
            style: TextStyle(
              color: const Color(0xFF6D756E),
              fontSize: 13,
              height: 1.4,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1D8B6B),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  device.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Result ──────────────────────────────────────────────────────────────

class _ResultView extends StatefulWidget {
  const _ResultView({
    required this.color,
    required this.icon,
    required this.fields,
    required this.values,
    required this.measuredAt,
    required this.status,
    required this.device,
    required this.onRescan,
  });
  final Color color;
  final IconData icon;
  final List<VitalFieldConfig> fields;
  final List<String> values;
  final DateTime measuredAt;
  final _StatusInfo? status;
  final MockDevice device;
  final VoidCallback onRescan;

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _checkPulse;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _checkPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _checkPulse.dispose();
    super.dispose();
  }

  double _stage(double start, double end, {Curve curve = Curves.easeOutCubic}) {
    final u = ((_enter.value - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(u);
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String _formatDate(DateTime t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(t.year, t.month, t.day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'วันนี้';
    if (diff == 1) return 'เมื่อวาน';
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return '${t.day} ${months[t.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (_, __) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const SizedBox(height: 8),
            _buildCheckmark(),
            const SizedBox(height: 22),
            _buildTitle(),
            const SizedBox(height: 24),
            _buildHeroCard(),
            if (widget.status != null) ...[
              const SizedBox(height: 14),
              _buildStatusBadge(widget.status!),
            ],
            const SizedBox(height: 16),
            _buildInfoRow(),
            const SizedBox(height: 20),
            _buildRescanButton(),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(_StatusInfo status) {
    final op = _stage(0.5, 0.85);
    final scale = 0.92 + op * 0.08;
    return Opacity(
      opacity: op,
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: status.color.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 15, color: status.color),
                const SizedBox(width: 7),
                Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckmark() {
    final scale = _stage(0.0, 0.55, curve: Curves.elasticOut);
    final opacity = _stage(0.0, 0.3);
    return Center(
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale,
          child: AnimatedBuilder(
            animation: _checkPulse,
            builder: (_, __) {
              final pulse = math.sin(_checkPulse.value * math.pi * 2);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1D8B6B)
                          .withValues(alpha: 0.08 + pulse.abs() * 0.04),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1D8B6B).withValues(alpha: 0.16),
                    ),
                  ),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF26A37E), Color(0xFF157F5E)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D8B6B)
                              .withValues(alpha: 0.4),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: CupertinoColors.white,
                      size: 42,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final op = _stage(0.2, 0.5);
    final dy = (1 - op) * 10;
    return Opacity(
      opacity: op,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: const Column(
          children: [
            Text(
              'วัดเสร็จแล้ว',
              style: TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'ผลการวัดของคุณ',
              style: TextStyle(
                color: Color(0xFF6D756E),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final op = _stage(0.35, 0.75);
    final dy = (1 - op) * 16;
    final multiField = widget.fields.length > 1;
    return Opacity(
      opacity: op,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.18),
                widget.color.withValues(alpha: 0.04),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: multiField ? 22 : 28,
            ),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: multiField
                ? _buildMultiFieldRow()
                : _buildSingleField(),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleField() {
    return Column(
      children: [
        Text(
          widget.fields[0].label,
          style: const TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.values[0],
              style: TextStyle(
                color: widget.color,
                fontSize: 64,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                widget.fields[0].unit,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiFieldRow() {
    if (widget.fields.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildFieldTile(0)),
          Container(
            width: 0.5,
            height: 72,
            color: const Color(0xFFEDEDF0),
          ),
          Expanded(child: _buildFieldTile(1)),
        ],
      );
    }
    return Column(
      children: [
        for (int i = 0; i < widget.fields.length; i++) ...[
          if (i > 0)
            Container(
              height: 0.5,
              margin: const EdgeInsets.symmetric(vertical: 14),
              color: const Color(0xFFEDEDF0),
            ),
          _buildFieldTile(i),
        ],
      ],
    );
  }

  Widget _buildFieldTile(int i) {
    return Column(
      children: [
        Text(
          widget.fields[i].label,
          style: const TextStyle(
            color: Color(0xFF6D756E),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              widget.values[i],
              style: TextStyle(
                color: widget.color,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.fields[i].unit,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    final op = _stage(0.55, 0.85);
    final dy = (1 - op) * 10;
    return Opacity(
      opacity: op,
      child: Transform.translate(
        offset: Offset(0, dy),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _infoPill(
              icon: CupertinoIcons.clock,
              text:
                  '${_formatDate(widget.measuredAt)} · ${_formatTime(widget.measuredAt)}',
            ),
            const SizedBox(width: 8),
            _infoPill(
              icon: CupertinoIcons.bluetooth,
              text: widget.device.name,
              dotColor: const Color(0xFF1D8B6B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String text,
    Color? dotColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFEDEDF0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
            const SizedBox(width: 6),
          ] else ...[
            Icon(icon, size: 12, color: const Color(0xFF6D756E)),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRescanButton() {
    final op = _stage(0.7, 1.0);
    return Opacity(
      opacity: op,
      child: Center(
        child: PressEffect(
          onTap: widget.onRescan,
          haptic: HapticKind.selection,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.arrow_clockwise,
                  size: 13,
                  color: Color(0xFF6D756E),
                ),
                SizedBox(width: 6),
                Text(
                  'วัดอีกครั้ง',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pulse ring animation ───────────────────────────────────────────────

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.controller,
    required this.color,
    required this.icon,
    this.scale = 1.0,
  });
  final Animation<double> controller;
  final Color color;
  final IconData icon;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160 * scale,
      height: 160 * scale,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final t = controller.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              // outer ring
              Transform.scale(
                scale: 0.6 + t * 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: (1 - t) * 0.18),
                  ),
                ),
              ),
              // middle ring
              Transform.scale(
                scale: 0.5 + t * 0.35,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: (1 - t) * 0.3),
                  ),
                ),
              ),
              // center icon
              Container(
                width: 80 * scale,
                height: 80 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: CupertinoColors.white,
                  size: 36 * scale,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
