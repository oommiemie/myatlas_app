import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';

import '../../core/widgets/liquid_glass_button.dart';
import 'widgets/youtube_clip_view.dart';

/// คำเตือนจากระบบตรวจท่าทาง แสดงแทนแถบคะแนนเมื่อกล้องจับท่าไม่ได้
class WorkoutCoachAlert {
  const WorkoutCoachAlert({required this.title, required this.message});
  final String title;
  final String message;
}

/// หน้าเล่นคลิปออกกำลังกาย (Figma 1456:16553 / 1456:16800)
///
/// พื้นดำเต็มจอ — บนสุดเป็นหัวคลิป ถัดมาเป็นแถบคะแนน/ความแม่นยำ
/// หรือการ์ดคำเตือนเมื่อระบบจับท่าไม่ได้ กลางจอเป็นวิดีโอพร้อมปุ่มควบคุม
/// มุมขวาเป็นภาพจากกล้องผู้ใช้ และล่างสุดเป็นแถบความคืบหน้าของคลิป
class WorkoutPlayerScreen extends StatefulWidget {
  const WorkoutPlayerScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverImage,
    this.coverUrl,
    this.youtubeId,
    this.minutes = 15,
    this.score = 10000,
    this.accuracy = 30,
    this.coachAlert,
  });

  final String title;
  final String subtitle;
  final String coverImage;

  /// หน้าปกจริงจากเครือข่าย ถ้ามีจะใช้แทนภาพในแอป
  final String? coverUrl;

  /// รหัสคลิป YouTube — มีแล้วจะเล่นคลิปจริงแทนภาพปก
  final String? youtubeId;
  final int minutes;
  final int score;
  final int accuracy;

  /// null = แสดงแถบคะแนนตามปกติ
  final WorkoutCoachAlert? coachAlert;

  @override
  State<WorkoutPlayerScreen> createState() => _WorkoutPlayerScreenState();
}

class _WorkoutPlayerScreenState extends State<WorkoutPlayerScreen> {
  /// เวลาที่เล่นไปแล้ว หน่วยวินาที — เดินเองเพื่อให้เห็นแถบความคืบหน้าขยับ
  double _elapsed = 0;
  bool _playing = true;
  Timer? _ticker;

  /// กล้องหน้าไว้จับท่าทาง null = ยังเปิดไม่ได้ (ไม่มีสิทธิ์ / ไม่มีกล้อง)
  CameraController? _camera;
  bool _cameraFailed = false;

  /// มุมที่กรอบกล้องเกาะอยู่ 0=บนซ้าย 1=บนขวา 2=ล่างซ้าย 3=ล่างขวา
  int _pipCorner = 3;

  /// ตำแหน่งระหว่างลาก ปล่อยนิ้วแล้วจะดีดไปมุมที่ใกล้ที่สุด
  Offset? _pipDrag;

  /// ปุ่มควบคุมแบบ YouTube — ไม่แตะจอสักพักจะซ่อน แตะจอเพื่อเรียกกลับ
  bool _controlsVisible = true;
  Timer? _hideTimer;
  static const _hideAfter = Duration(seconds: 3);

  /// คำเตือนจากระบบตรวจท่าทาง แสดงแทนแถบคะแนนชั่วคราว
  WorkoutCoachAlert? _alert;
  Timer? _alertTimer;
  Timer? _detector;

  static const _anyOrientation = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// กรอบกล้องเล็กลงเมื่อเป็นแนวนอน เพราะความสูงจอน้อย
  Size _pipSize(bool landscape) =>
      landscape ? const Size(104, 134) : const Size(127, 163);

  /// จำทิศล่าสุด ใช้ซ่อน/คืนแถบสถานะเมื่อหมุนจอ
  bool? _wasLandscape;

  /// ปุ่มหมุนจอแบบ YouTube — บังคับแนวนอน/แนวตั้งตามที่กด
  void _toggleOrientation(bool landscape) {
    _pokeControls(() {});
    SystemChrome.setPreferredOrientations(
      landscape
          ? const [DeviceOrientation.portraitUp]
          : const [
              DeviceOrientation.landscapeLeft,
              DeviceOrientation.landscapeRight,
            ],
    );
  }

  /// ความยาวคลิปจริงจาก YouTube (วินาที) ถ้ายังไม่รู้ใช้ค่าจากข้อมูลคลิป
  double? _videoLength;
  double get _total => _videoLength ?? widget.minutes * 60;

  final _video = YoutubeClipController();

  @override
  void initState() {
    super.initState();
    _alert = widget.coachAlert;
    // หน้าเล่นคลิปหมุนเป็นแนวนอนได้ ส่วนหน้าอื่นของแอปล็อกแนวตั้ง
    SystemChrome.setPreferredOrientations(_anyOrientation);
    _openCamera();
    _watchBodyDetection();
    _scheduleHide();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (widget.youtubeId != null) return;
      if (!_playing || !mounted) return;
      setState(() => _elapsed = (_elapsed + 1).clamp(0, _total));
    });
  }

  /// เปิดกล้องหน้า ถ้าไม่ได้รับสิทธิ์หรือไม่มีกล้องจะกลับไปใช้ภาพแทน
  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _camera = controller);
    } catch (_) {
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  /// ตั้งเวลาซ่อนปุ่มควบคุม — ซ่อนเฉพาะตอนกำลังเล่น หยุดไว้จะค้างให้เห็น
  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_playing) return;
    _hideTimer = Timer(_hideAfter, () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  /// แตะจอ — สลับแสดง/ซ่อนปุ่มควบคุม
  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _scheduleHide();
    } else {
      _hideTimer?.cancel();
    }
  }

  /// กดปุ่มควบคุมใด ๆ — คงให้เห็นต่อแล้วเริ่มนับเวลาซ่อนใหม่
  void _pokeControls(VoidCallback action) {
    setState(() {
      action();
      _controlsVisible = true;
    });
    _scheduleHide();
  }

  /// เฝ้าผลตรวจจับร่างกาย — ตอนนี้เป็นการจำลอง
  /// เมื่อต่อโมเดลตรวจท่าจริงให้เรียก [showCoachAlert] จากผลตรวจแทน
  void _watchBodyDetection() {
    _detector = Timer.periodic(const Duration(seconds: 12), (_) {
      if (!mounted || !_playing) return;
      if (_alert != null) return;
      showCoachAlert(
        const WorkoutCoachAlert(
          title: 'ถอยห่างจากกล้อง',
          message: 'ถอยให้ห่างจนเห็นเต็มตัว ระบบถึงจะนับคะแนนได้',
        ),
      );
    });
  }

  /// แจ้งเตือนเมื่อระบบจับร่างกายไม่ได้ ปิดเองใน 4 วินาที
  void showCoachAlert(WorkoutCoachAlert alert) {
    _alertTimer?.cancel();
    setState(() => _alert = alert);
    _alertTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _alert = null);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _alertTimer?.cancel();
    _detector?.cancel();
    _hideTimer?.cancel();
    _camera?.dispose();
    // ออกจากหน้าเล่น — กลับไปล็อกแนวตั้งและคืนแถบสถานะ
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  String get _timeLabel {
    String fmt(double s) {
      final m = s ~/ 60;
      final sec = (s % 60).toInt();
      return '$m.${sec.toString().padLeft(2, '0')}';
    }

    return '${fmt(_elapsed)}/${fmt(_total)}';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final landscape = media.orientation == Orientation.landscape;
    final pad = media.padding;
    final alert = _alert;
    final show = _controlsVisible;

    // แนวนอนซ่อนแถบสถานะ ให้วิดีโอเต็มจอแบบ YouTube
    if (_wasLandscape != landscape) {
      _wasLandscape = landscape;
      SystemChrome.setEnabledSystemUIMode(
        landscape ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      );
    }

    // ระยะขอบเผื่อรอยบาก — แนวนอนรอยบากอยู่ซ้าย/ขวา
    final left = pad.left + 16;
    final right = pad.right + 16;
    final headerTop = landscape ? 12.0 : pad.top + 8;
    final scoreTop = show ? headerTop + 68 : headerTop;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          // ชั้นหลังสุดรับการแตะจอ เพื่อเรียก/ซ่อนปุ่มควบคุม
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggleControls,
              child: const SizedBox.expand(),
            ),
          ),

          // วิดีโอ — แนวตั้งวางกลางจอตามแบบ แนวนอนเต็มจอ
          Positioned(
            left: 0,
            right: 0,
            top: landscape ? 0 : 238,
            height: landscape ? media.size.height : 401,
            // ไม่รับการแตะ ให้การแตะไปถึงชั้นหลังเพื่อเรียก/ซ่อนปุ่มควบคุม
            child: IgnorePointer(child: _videoLayer()),
          ),

          // แนวนอน: ไล่ดำบน-ล่างให้ตัวหนังสือบนวิดีโออ่านออก (ซ่อนพร้อมปุ่ม)
          if (landscape) ...[
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 140,
              child: IgnorePointer(
                child: _autoHide(show, child: const _Scrim(top: true)),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 120,
              child: IgnorePointer(
                child: _autoHide(show, child: const _Scrim(top: false)),
              ),
            ),
          ],

          // หัวคลิป: ภาพย่อ ชื่อ ปุ่มหมุนจอ และปุ่มปิด — ซ่อนได้
          Positioned(
            left: left,
            right: right,
            top: headerTop,
            child: _autoHide(show, offsetY: -0.3, child: _header(landscape)),
          ),

          // แถบคะแนน/คำเตือน แสดงตลอด เลื่อนขึ้นแทนที่หัวคลิปตอนซ่อน
          // แนวนอนจำกัดความกว้าง ไม่ให้บังวิดีโอทั้งแถบ
          AnimatedPositioned(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            left: left,
            right: landscape ? null : right,
            width: landscape ? 380 : null,
            top: scoreTop,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.15),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: alert == null
                  ? _scoreBar()
                  : KeyedSubtree(
                      key: ValueKey(alert.title),
                      child: _coachCard(alert),
                    ),
            ),
          ),

          // กล้องหน้า ลากแล้วดีดไปเกาะมุมที่ใกล้ที่สุด
          _snappingCamera(context, landscape),

          // ปุ่มควบคุมการเล่น — ซ่อนได้ แนวนอนอยู่กึ่งกลางจอ
          Positioned(
            left: 0,
            right: 0,
            top: landscape ? (media.size.height - 52) / 2 : 414,
            child: _autoHide(show, child: _playControls()),
          ),

          // แถบเวลาของคลิป — ซ่อนได้
          Positioned(
            left: left,
            right: right,
            bottom: landscape ? pad.bottom + 12 : pad.bottom + 16,
            child: _autoHide(show, offsetY: 0.3, child: _progressBar()),
          ),
        ],
      ),
    );
  }

  Widget _videoLayer() {
    if (widget.youtubeId == null) return _cover();
    return YoutubeClipView(
      videoId: widget.youtubeId!,
      controller: _video,
      onReady: (len) {
        if (mounted && len > 0) setState(() => _videoLength = len);
      },
      onTime: (t) {
        if (mounted) setState(() => _elapsed = t);
      },
      onPlayingChanged: (playing) {
        if (!mounted || playing == _playing) return;
        setState(() => _playing = playing);
        if (playing) _scheduleHide();
      },
    );
  }

  Widget _playControls() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LiquidGlassButton(
            icon: CupertinoIcons.gobackward_10,
            onTap: () => _pokeControls(() {
              _elapsed = (_elapsed - 10).clamp(0, _total);
              _video.seekTo(_elapsed);
            }),
            size: 44,
            iconSize: 20,
          ),
          const SizedBox(width: 16),
          LiquidGlassButton(
            icon: _playing
                ? CupertinoIcons.pause_fill
                : CupertinoIcons.play_fill,
            onTap: () => _pokeControls(() {
              _playing = !_playing;
              _playing ? _video.play() : _video.pause();
            }),
            size: 52,
            iconSize: 22,
          ),
          const SizedBox(width: 16),
          LiquidGlassButton(
            icon: CupertinoIcons.goforward_10,
            onTap: () => _pokeControls(() {
              _elapsed = (_elapsed + 10).clamp(0, _total);
              _video.seekTo(_elapsed);
            }),
            size: 44,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  /// ภาพปกคลิป — หน้าปกจริงถ้ามี ระหว่างโหลดหรือโหลดไม่ได้ใช้ภาพในแอป
  Widget _cover() {
    final fallback = Image.asset(widget.coverImage, fit: BoxFit.cover);
    final url = widget.coverUrl;
    if (url == null) return fallback;
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback,
      errorBuilder: (_, _, _) => fallback,
    );
  }

  /// ห่อส่วนที่ซ่อนได้ — จางหายพร้อมเลื่อนออกเล็กน้อย และกดไม่ได้ตอนซ่อน
  Widget _autoHide(bool visible, {required Widget child, double offsetY = 0}) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        opacity: visible ? 1 : 0,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : Offset(0, offsetY),
          child: child,
        ),
      ),
    );
  }

  Widget _header(bool landscape) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 48, height: 48, child: _cover()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: CupertinoColors.white,
                ),
              ),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: _fontThai,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  leadingDistribution: TextLeadingDistribution.even,
                  color: CupertinoColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // หมุนจอ แนวตั้ง ↔ แนวนอน
        LiquidGlassButton(
          icon: landscape
              ? CupertinoIcons.fullscreen_exit
              : CupertinoIcons.fullscreen,
          onTap: () => _toggleOrientation(landscape),
          size: 44,
          iconSize: 18,
        ),
        const SizedBox(width: 8),
        LiquidGlassButton(
          icon: CupertinoIcons.xmark,
          onTap: () => Navigator.of(context).maybePop(),
          size: 44,
          iconSize: 18,
        ),
      ],
    );
  }

  /// แถบคะแนนฝ้าโปร่ง — คะแนนที่ได้ และความแม่นยำพร้อมหลอด
  Widget _scoreBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: CupertinoColors.white.withValues(alpha: 0.2),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.drop_fill,
                size: 32,
                color: Color(0xFF2FA1FF),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _label('คะแนนที่ได้'),
                  Text(
                    _thousands(widget.score),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      fontVariations: [FontVariation('wght', 800)],
                      height: 1.2,
                      color: CupertinoColors.white,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _label('ความแม่นยำ'),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 12,
                              child: Stack(
                                children: [
                                  const ColoredBox(
                                    color: Color(0xFFE5E5E5),
                                    child: SizedBox.expand(),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: (widget.accuracy / 100).clamp(
                                      0.0,
                                      1.0,
                                    ),
                                    child: ColoredBox(
                                      color: _accuracyTone(widget.accuracy),
                                      child: const SizedBox.expand(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${widget.accuracy}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            fontVariations: [FontVariation('wght', 800)],
                            height: 1.2,
                            color: CupertinoColors.white,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: _fontThai,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      leadingDistribution: TextLeadingDistribution.even,
      color: CupertinoColors.white.withValues(alpha: 0.8),
    ),
  );

  /// การ์ดคำเตือนจากระบบตรวจท่าทาง — พื้นขาวย้อมแดงจาง
  Widget _coachCard(WorkoutCoachAlert alert) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          _danger.withValues(alpha: 0.15),
          CupertinoColors.white,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CupertinoColors.white),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, size: 24, color: _danger),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: _danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: const TextStyle(
                    fontFamily: _fontThai,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                    leadingDistribution: TextLeadingDistribution.even,
                    color: _danger,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ตำแหน่งมุมทั้งสี่ที่กรอบกล้องเกาะได้ — เว้นพื้นที่แถบคะแนนด้านบน
  /// และแถบเวลาด้านล่างไว้ กรอบจึงไม่บังข้อมูลสำคัญ
  List<Offset> _pipAnchors(BuildContext context, bool landscape) {
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final pip = _pipSize(landscape);
    final left = pad.left + 16;
    final right = size.width - pad.right - pip.width - 16;
    // แนวนอน: มุมบนอยู่ใต้หัวคลิป (แถบคะแนนอยู่ซ้าย ไม่ชนมุมขวา)
    final upper = landscape ? 12 + 60.0 : pad.top + 180;
    final lower = landscape
        ? size.height - pad.bottom - 12 - 50 - 8 - pip.height
        : size.height - pad.bottom - 16 - 50 - 12 - pip.height;
    return [
      Offset(left, upper),
      Offset(right, upper),
      Offset(left, lower),
      Offset(right, lower),
    ];
  }

  /// กรอบกล้องหน้า ลากได้แล้วดีดไปเกาะมุมที่ใกล้ที่สุด (แบบ FaceTime)
  Widget _snappingCamera(BuildContext context, bool landscape) {
    final anchors = _pipAnchors(context, landscape);
    final dragging = _pipDrag != null;
    final pos = _pipDrag ?? anchors[_pipCorner];

    return AnimatedPositioned(
      // ระหว่างลากตามนิ้วทันที ปล่อยแล้วค่อยดีดแบบมีสปริงนิด ๆ
      duration: dragging ? Duration.zero : const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      left: pos.dx,
      top: pos.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (_) => setState(() => _pipDrag = anchors[_pipCorner]),
        onPanUpdate: (d) =>
            setState(() => _pipDrag = (_pipDrag ?? pos) + d.delta),
        onPanEnd: (d) {
          final current = _pipDrag ?? pos;
          // เผื่อแรงเหวี่ยง: ปัดเร็วไปทางไหนให้ไปมุมฝั่งนั้น
          final projected = current + d.velocity.pixelsPerSecond * 0.12;
          var best = 0;
          var bestDist = double.infinity;
          for (var i = 0; i < anchors.length; i++) {
            final dist = (anchors[i] - projected).distance;
            if (dist < bestDist) {
              bestDist = dist;
              best = i;
            }
          }
          setState(() {
            _pipCorner = best;
            _pipDrag = null;
          });
        },
        child: _cameraPreview(landscape),
      ),
    );
  }

  /// ภาพจากกล้องหน้า ถ้าเปิดไม่ได้จะแสดงภาพคลิปพร้อมไอคอนกล้องปิดแทน
  Widget _cameraPreview(bool landscape) {
    final controller = _camera;
    final ready = controller != null && controller.value.isInitialized;
    final pip = _pipSize(landscape);
    return Container(
      width: pip.width,
      height: pip.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CupertinoColors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCDCDC)),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ready
          // กล้องหน้าแสดงแบบกระจกเงา ผู้ใช้จึงขยับตามได้ง่าย
          ? Transform.flip(
              flipX: true,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 127,
                  height: controller.value.previewSize?.width ?? 163,
                  child: CameraPreview(controller),
                ),
              ),
            )
          // ยังไม่มีภาพกล้อง — พื้นเข้มพร้อมสถานะ ไม่ใช้หน้าปกคลิป
          // เพื่อไม่ให้ดูเหมือนคลิปไปเล่นอยู่ในกรอบเล็ก
          : ColoredBox(
              color: const Color(0xFF1C1C1E),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _cameraFailed
                          ? CupertinoIcons.video_camera
                          : CupertinoIcons.camera,
                      size: 24,
                      color: CupertinoColors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _cameraFailed ? 'เปิดกล้องไม่ได้' : 'กำลังเปิดกล้อง',
                      style: TextStyle(
                        fontFamily: _fontThai,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// แถบเวลาของคลิป
  Widget _progressBar() {
    final ratio = _total == 0 ? 0.0 : (_elapsed / _total).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: CupertinoColors.white.withValues(alpha: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeLabel,
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: CupertinoColors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 10,
                  child: Stack(
                    children: [
                      const ColoredBox(
                        color: Color(0xFFF5F5F5),
                        child: SizedBox.expand(),
                      ),
                      FractionallySizedBox(
                        widthFactor: ratio == 0 ? 0.015 : ratio,
                        child: const ColoredBox(
                          color: Color(0xFFE62E05),
                          child: SizedBox.expand(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _fontThai = 'IBM Plex Sans Thai Looped';
const _danger = Color(0xFFFF383C);

/// เกณฑ์สีของความแม่นยำ ชุดเดียวกับหน้าออกกำลังกาย
Color _accuracyTone(int accuracy) {
  if (accuracy < 40) return const Color(0xFFE62E05);
  if (accuracy < 70) return const Color(0xFFEFA83A);
  return const Color(0xFF3E9B1E);
}

String _thousands(int value) =>
    '$value'.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

/// ไล่สีดำจางที่ขอบบน/ล่างของวิดีโอแนวนอน ให้ปุ่มและตัวหนังสืออ่านออก
class _Scrim extends StatelessWidget {
  const _Scrim({required this.top});
  final bool top;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: top ? Alignment.topCenter : Alignment.bottomCenter,
        end: top ? Alignment.bottomCenter : Alignment.topCenter,
        colors: const [Color(0x99000000), Color(0x00000000)],
      ),
    ),
  );
}
