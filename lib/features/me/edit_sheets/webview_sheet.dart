import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/widgets/liquid_glass_button.dart';

/// Bottom-sheet WebView used for connecting external accounts
/// (Google / Facebook / Apple / Health ID).
///
/// Pushes a route that slides up from the bottom and renders the given [url]
/// inside a sandboxed [WebViewWidget].
Future<void> showWebViewSheet(
  BuildContext context, {
  required String title,
  required String url,
}) {
  return Navigator.of(context, rootNavigator: true).push<void>(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: CupertinoColors.black.withValues(alpha: 0.4),
      barrierDismissible: true,
      barrierLabel: 'webview-sheet',
      transitionDuration: const Duration(milliseconds: 380),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, anim, sec) => _WebViewSheet(title: title, url: url),
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

class _WebViewSheet extends StatefulWidget {
  const _WebViewSheet({required this.title, required this.url});
  final String title;
  final String url;

  @override
  State<_WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<_WebViewSheet> {
  late final WebViewController _controller;
  String _host = '';
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _host = Uri.tryParse(widget.url)?.host ?? '';
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100),
          onPageStarted: (_) => setState(() => _progress = 0.05),
          onPageFinished: (_) => setState(() => _progress = 1),
          onUrlChange: (c) {
            final u = c.url;
            if (u != null) {
              final h = Uri.tryParse(u)?.host;
              if (h != null && h != _host) setState(() => _host = h);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: const Color(0xFFF2F2F7),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      LiquidGlassButton(
                        icon: CupertinoIcons.xmark,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(
                              _host.isEmpty ? widget.title : _host,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      LiquidGlassButton(
                        icon: CupertinoIcons.refresh,
                        iconColor: const Color(0xFF1A1A1A),
                        onTap: () => _controller.reload(),
                      ),
                    ],
                  ),
                ),
                if (_progress > 0 && _progress < 1)
                  Container(
                    height: 2,
                    color: const Color(0xFFE5E5E5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 180),
                        widthFactor: _progress,
                        heightFactor: 1,
                        child: const ColoredBox(
                          color: Color(0xFF1D8B6B),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Container(
                    color: CupertinoColors.white,
                    margin: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: WebViewWidget(controller: _controller),
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
