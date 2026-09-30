import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// ภาพปกของคลิป YouTube — ใช้ขนาดกลางที่มีให้ทุกคลิปเสมอ
String youtubeThumbnail(String videoId) =>
    'https://i.ytimg.com/vi/$videoId/hqdefault.jpg';

/// ตัวคุมคลิป YouTube จากฝั่ง Flutter — เล่น หยุด และเลื่อนเวลา
class YoutubeClipController {
  WebViewController? _web;

  Future<void> play() => _player('m.playVideo()');
  Future<void> pause() => _player('m.pauseVideo()');
  Future<void> seekTo(double seconds) =>
      _player('m.seekTo(${seconds.toStringAsFixed(1)}, true)');

  /// สั่ง player ของหน้า embed (element id = movie_player)
  Future<void> _player(String js) async {
    final web = _web;
    if (web == null) return;
    try {
      await web.runJavaScript(
        "(function(){var m=document.getElementById('movie_player');"
        "if(m&&m.playVideo){ $js; }})()",
      );
    } catch (_) {
      // หน้าเพิ่งเปลี่ยน/ยังโหลดไม่เสร็จ — ข้ามไป
    }
  }
}

/// คลิป YouTube แบบฝังในหน้า
///
/// โหลดหน้า embed ของ YouTube ตรง ๆ พร้อม Referer ของแอป เพราะ YouTube
/// ปฏิเสธการฝังที่ไม่ระบุแหล่งที่มา (ข้อผิดพลาด 152) จากนั้นซ่อนปุ่มของ
/// YouTube ทั้งหมด ครอปภาพเต็มกรอบ และให้ปุ่มของแอปสั่งงานแทน
class YoutubeClipView extends StatefulWidget {
  const YoutubeClipView({
    super.key,
    required this.videoId,
    required this.controller,
    this.onReady,
    this.onTime,
    this.onPlayingChanged,
  });

  final String videoId;
  final YoutubeClipController controller;

  /// ได้ความยาวคลิปเป็นวินาทีเมื่อโหลดเสร็จ
  final ValueChanged<double>? onReady;

  /// เวลาปัจจุบันของคลิป ส่งมาทุกครึ่งวินาที
  final ValueChanged<double>? onTime;

  /// สถานะเล่น/หยุดที่เปลี่ยนจากฝั่งคลิป (เช่น คลิปจบ)
  final ValueChanged<bool>? onPlayingChanged;

  @override
  State<YoutubeClipView> createState() => _YoutubeClipViewState();
}

class _YoutubeClipViewState extends State<YoutubeClipView> {
  late final WebViewController _web;
  Timer? _poll;
  bool _readySent = false;
  bool? _lastPlaying;

  static const _appOrigin = 'https://myatlas.app';

  @override
  void initState() {
    super.initState();
    // iOS: เล่นในหน้าได้เลย ไม่เด้งเต็มจอ และเริ่มเล่นเองได้โดยไม่ต้องแตะ
    final params = WebViewPlatform.instance is WebKitWebViewPlatform
        ? WebKitWebViewControllerCreationParams(
            allowsInlineMediaPlayback: true,
            mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
          )
        : const PlatformWebViewControllerCreationParams();

    final url = Uri.https('www.youtube.com', '/embed/${widget.videoId}', {
      'playsinline': '1',
      'autoplay': '1',
      'controls': '0',
      'disablekb': '1',
      'fs': '0',
      'rel': '0',
      'iv_load_policy': '3',
      'modestbranding': '1',
      'origin': _appOrigin,
    });

    _web = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF000000))
      ..setNavigationDelegate(
        NavigationDelegate(onPageFinished: (_) => _decorate()),
      )
      ..loadRequest(url, headers: const {'Referer': '$_appOrigin/'});
    widget.controller._web = _web;

    // ถามสถานะคลิปทุกครึ่งวินาที และตกแต่งหน้าซ้ำ เผื่อ YouTube วาดปุ่มกลับมา
    _poll = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
  }

  /// ซ่อนปุ่มและลายน้ำของ YouTube แล้วครอปวิดีโอให้เต็มกรอบแบบ cover
  Future<void> _decorate() async {
    const css =
        'html,body{background:#000!important;margin:0;overflow:hidden}'
        '.ytp-chrome-top,.ytp-chrome-bottom,.ytp-gradient-top,'
        '.ytp-gradient-bottom,.ytp-watermark,.ytp-pause-overlay,'
        '.ytp-large-play-button,.ytp-spinner,.ytp-show-cards-title,'
        '.ytp-ce-element,.ytp-paid-content-overlay{display:none!important}'
        '.html5-video-container,video{width:100%!important;'
        'height:100%!important;left:0!important;top:0!important}'
        'video{object-fit:cover!important}';
    try {
      await _web.runJavaScript(
        "(function(){if(document.getElementById('myatlas-css'))return;"
        "var s=document.createElement('style');s.id='myatlas-css';"
        "s.textContent=${jsonEncode(css)};document.head.appendChild(s);"
        "var m=document.getElementById('movie_player');"
        "if(m&&m.playVideo){m.playVideo();}})()",
      );
    } catch (_) {}
  }

  Future<void> _tick() async {
    if (!mounted) return;
    try {
      final raw = await _web.runJavaScriptReturningResult(
        "(function(){var m=document.getElementById('movie_player');"
        "var v=document.querySelector('video');"
        "var st=(m&&m.getPlayerState)?m.getPlayerState():-9;"
        "return JSON.stringify({t:m&&m.getCurrentTime?m.getCurrentTime():0,"
        "d:m&&m.getDuration?m.getDuration():0,p:st===1,st:st,"
        "rs:v?v.readyState:-1,w:v?v.clientWidth:-1,"
        "title:document.title,"
        "err:(document.querySelector('.ytp-error-content-wrap-reason')||{}).innerText||''});})()",
      );
      var text = raw.toString();
      // iOS คืนค่าเป็นสตริงที่ห่อด้วยเครื่องหมายคำพูดอีกชั้น
      if (text.startsWith('"')) text = jsonDecode(text) as String;
      if (text.isEmpty) return;
      final data = jsonDecode(text) as Map<String, dynamic>;
      final t = (data['t'] as num?)?.toDouble() ?? 0;
      final d = (data['d'] as num?)?.toDouble() ?? 0;
      final playing = data['p'] == true;

      if (!_readySent && d > 0 && d.isFinite) {
        _readySent = true;
        widget.onReady?.call(d);
        _decorate();
        await widget.controller.play();
      }
      widget.onTime?.call(t);
      if (_lastPlaying != playing) {
        _lastPlaying = playing;
        widget.onPlayingChanged?.call(playing);
      }
    } catch (_) {
      // หน้ายังโหลดไม่เสร็จ
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    widget.controller._web = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WebViewWidget(controller: _web);
}
