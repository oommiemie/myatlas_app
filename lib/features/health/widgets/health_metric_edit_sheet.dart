import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Material, ReorderableDragStartListener, ReorderableListView, Theme, ThemeData;
import 'package:flutter/services.dart';

import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/liquid_glass_button.dart';
import '../../../core/widgets/press_effect.dart';
import '../blood_pressure_detail_screen.dart';
import '../blood_sugar_detail_screen.dart';
import '../bmi_detail_screen.dart';
import '../cgm_detail_screen.dart';
import '../heart_rate_detail_screen.dart';
import '../sleep_detail_screen.dart';
import '../spo2_detail_screen.dart';
import '../temperature_detail_screen.dart';
import '../waist_detail_screen.dart';
import '../health_metric_prefs.dart';

/// Bottom sheet showing the user's health metrics as a menu. Tap a row to
/// open that metric's detail screen. Tap the pencil button to enter
/// "edit mode" where rows can be pinned/unpinned and reordered by drag.
Future<void> showHealthMetricEditSheet(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const _HealthMetricEditSheet(),
      transitionsBuilder: (_, anim, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: anim,
              curve: Curves.fastEaseInToSlowEaseOut,
              reverseCurve: Curves.easeInCubic,
            ),
          ),
          child: child,
        );
      },
    ),
  );
}

Widget _detailScreenFor(HealthMetricKey key) {
  switch (key) {
    case HealthMetricKey.bloodPressure:
      return const BloodPressureDetailScreen();
    case HealthMetricKey.bmi:
      return const BmiDetailScreen();
    case HealthMetricKey.temperature:
      return const TemperatureDetailScreen();
    case HealthMetricKey.sleep:
      return const SleepDetailScreen();
    case HealthMetricKey.heartRate:
      return const HeartRateDetailScreen();
    case HealthMetricKey.cgm:
      return const CgmDetailScreen();
    case HealthMetricKey.waist:
      return const WaistDetailScreen();
    case HealthMetricKey.spo2:
      return const Spo2DetailScreen();
    case HealthMetricKey.bloodSugar:
      return const BloodSugarDetailScreen();
  }
}

class _HealthMetricEditSheet extends StatefulWidget {
  const _HealthMetricEditSheet();

  @override
  State<_HealthMetricEditSheet> createState() => _HealthMetricEditSheetState();
}

class _HealthMetricEditSheetState extends State<_HealthMetricEditSheet> {
  late List<HealthMetricKey> _order;
  late Set<HealthMetricKey> _pinned;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final prefs = healthMetricPrefsStore.value;
    _order = List.of(prefs.order);
    _pinned = Set.of(prefs.pinned);
  }

  void _togglePin(HealthMetricKey key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_pinned.contains(key)) {
        _pinned.remove(key);
      } else {
        _pinned.add(key);
      }
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
  }

  void _enterEditMode() {
    HapticFeedback.selectionClick();
    setState(() => _editing = true);
  }

  void _saveAndExitEditMode() {
    HapticFeedback.mediumImpact();
    healthMetricPrefsStore.value = HealthMetricPrefs(
      order: List.of(_order),
      pinned: Set.of(_pinned),
    );
    setState(() => _editing = false);
    AppToast.success(context, 'บันทึกการจัดเรียงแล้ว');
  }

  void _openDetail(HealthMetricKey key) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      CupertinoPageRoute(builder: (_) => _detailScreenFor(key)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
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
                color: const Color(0xFFF8F8FA).withValues(alpha: 0.94),
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
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1A1A1A).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Text(
                              _editing ? 'จัดเรียงข้อมูลสุขภาพ' : 'ข้อมูลสุขภาพ',
                              key: ValueKey(_editing),
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: LiquidGlassButton(
                              icon: CupertinoIcons.xmark,
                              iconColor: const Color(0xFF1A1A1A),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _editing
                                ? LiquidGlassButton(
                                    icon: CupertinoIcons.check_mark,
                                    iconColor: CupertinoColors.white,
                                    tint: const Color(0xFF1D8B6B),
                                    onTap: _saveAndExitEditMode,
                                  )
                                : LiquidGlassButton(
                                    icon: CupertinoIcons.pencil,
                                    iconColor: const Color(0xFF1D8B6B),
                                    onTap: _enterEditMode,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
                    child: Column(
                      children: [
                        Text(
                          _editing
                              ? 'ปักหมุดเพื่อแสดงในหน้าสรุปสุขภาพ'
                              : 'แตะเพื่อดูรายละเอียด',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6D756E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ปักหมุดแล้ว ${_pinned.length} จาก ${_order.length} รายการ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF1D8B6B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: _editing
                        ? _buildEditList(bottomInset)
                        : _buildBrowseList(bottomInset),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseList(double bottomInset) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
      itemCount: _order.length,
      itemBuilder: (_, i) {
        final k = _order[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _MetricRow(
            kind: k,
            pinned: _pinned.contains(k),
            mode: _RowMode.browse,
            onTap: () => _openDetail(k),
          ),
        );
      },
    );
  }

  Widget _buildEditList(double bottomInset) {
    return Theme(
      // ReorderableListView is Material — strip its default canvas color so
      // it inherits the sheet background.
      data: ThemeData(
        canvasColor: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
      ),
      child: ReorderableListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
        proxyDecorator: (child, _, anim) => AnimatedBuilder(
          animation: anim,
          builder: (_, __) {
            final t = Curves.easeOut.transform(anim.value);
            return Material(
              color: const Color(0x00000000),
              child: Transform.scale(scale: 1 + 0.025 * t, child: child),
            );
          },
        ),
        itemCount: _order.length,
        onReorder: _reorder,
        itemBuilder: (_, i) {
          final k = _order[i];
          return Padding(
            key: ValueKey(k),
            padding: const EdgeInsets.only(bottom: 8),
            child: _MetricRow(
              kind: k,
              pinned: _pinned.contains(k),
              mode: _RowMode.edit,
              onTogglePin: () => _togglePin(k),
              dragIndex: i,
            ),
          );
        },
      ),
    );
  }
}

enum _RowMode { browse, edit }

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.kind,
    required this.pinned,
    required this.mode,
    this.onTogglePin,
    this.onTap,
    this.dragIndex = 0,
  });

  final HealthMetricKey kind;
  final bool pinned;
  final _RowMode mode;
  final VoidCallback? onTogglePin;
  final VoidCallback? onTap;
  final int dragIndex;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF747480).withValues(alpha: 0.10),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: [
            // Left accent stripe — appears only when pinned.
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: pinned ? 4 : 0,
              decoration: BoxDecoration(color: kind.tone),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kind.tone.withValues(alpha: 0.16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(kind.icon, color: kind.tone, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kind.label,
                            style: TextStyle(
                              color: pinned
                                  ? const Color(0xFF1A1A1A)
                                  : const Color(0xFF6D756E),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pinned ? 'แสดงบนหน้าสรุป' : 'ไม่แสดง',
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (mode == _RowMode.edit) ...[
                      Transform.scale(
                        scale: 0.86,
                        child: CupertinoSwitch(
                          value: pinned,
                          activeTrackColor: const Color(0xFF1D8B6B),
                          onChanged: (_) => onTogglePin?.call(),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: dragIndex,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(6, 8, 4, 8),
                          child: Icon(
                            CupertinoIcons.line_horizontal_3,
                            color: Color(0xFFB0B0B5),
                            size: 22,
                          ),
                        ),
                      ),
                    ] else
                      const Padding(
                        padding: EdgeInsets.fromLTRB(6, 8, 4, 8),
                        child: Icon(
                          CupertinoIcons.chevron_right,
                          color: Color(0xFFB0B0B5),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (mode == _RowMode.browse && onTap != null) {
      return PressEffect(
        onTap: onTap,
        haptic: HapticKind.selection,
        scale: 0.985,
        borderRadius: BorderRadius.circular(18),
        child: card,
      );
    }
    return card;
  }
}
