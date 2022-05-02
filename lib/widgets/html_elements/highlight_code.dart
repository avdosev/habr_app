import 'package:flutter/material.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:habr_app/utils/worker/worker.dart';
import 'package:highlight/highlight.dart' show highlight, Node, Result;

class HighlightCode extends StatelessWidget {
  final String text;
  final String? language;
  final EdgeInsets? padding;
  final TextStyle? codeStyle;
  final ThemeMode? themeMode;
  final String themeNameDark;
  final String themeNameLight;

  HighlightCode(
    this.text, {
    this.language,
    this.padding,
    this.codeStyle,
    this.themeMode,
    this.themeNameDark = "androidstudio",
    this.themeNameLight = "github",
  });

  Widget build(BuildContext context) {
    final mode = _getThemeMode(context);

    Map<String, TextStyle>? theme;
    if (mode == ThemeMode.dark) {
      theme = themeMap[themeNameDark];
    } else {
      theme = themeMap[themeNameLight];
    }

    return _HighlightView(
      // The original code to be highlighted
      text,
      // Specify language
      // It is recommended to give it a value for performance
      language: language,
      autoDetection: language == null,
      padding: padding,

      // Specify highlight theme
      // All available themes are listed in `themes` folder
      theme: theme,

      // Specify text style
      textStyle: codeStyle ??
          const TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
          ),
    );
  }

  ThemeMode? _getThemeMode(BuildContext context) {
    var mode = themeMode;
    if (mode == null || mode == ThemeMode.system) {
      switch (Theme.of(context).brightness) {
        case Brightness.dark:
          mode = ThemeMode.dark;
          break;
        case Brightness.light:
          mode = ThemeMode.light;
          break;
      }
    }
    return mode;
  }

  static List<String> themes = themeMap.keys.toList();
}

/// Highlight Flutter Widget
class _HighlightView extends StatefulWidget {
  /// The original code to be highlighted
  final String source;

  /// Highlight language
  ///
  /// It is recommended to give it a value for performance
  ///
  /// [All available languages](https://github.com/pd4d10/highlight/tree/master/highlight/lib/languages)
  final String? language;

  /// Highlight theme
  ///
  /// [All available themes](https://github.com/pd4d10/highlight/blob/master/flutter_highlight/lib/themes)
  final Map<String, TextStyle>? theme;

  /// Padding
  final EdgeInsetsGeometry? padding;
  final bool? autoDetection;

  /// Text styles
  ///
  /// Specify text styles such as font family and font size
  final TextStyle? textStyle;

  _HighlightView(
    String input, {
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    this.autoDetection,
    int tabSize = 8, // TODO: https://github.com/flutter/flutter/issues/50087
  }) : source = input.replaceAll('\t', ' ' * tabSize);

  @override
  State<StatefulWidget> createState() {
    return _HighlightViewState();
  }
}

class _HighlightViewState extends State<_HighlightView> {
  static final parserWorker = Worker(name: "language_detector");
  Future<List<Node>?>? parsing;

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    _traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(
                text: node.value, style: widget.theme![node.className!]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans.add(
            TextSpan(children: tmp, style: widget.theme![node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;

        node.children!.forEach((n) {
          _traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        });
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }

    return spans;
  }

  static const _rootKey = 'root';
  static const _defaultFontColor = Color(0xff000000);
  static const _defaultBackgroundColor = Color(0xffffffff);

  // TODO: dart:io is not available at web platform currently
  // See: https://github.com/flutter/flutter/issues/39998
  // So we just use monospace here for now
  static const _defaultFontFamily = 'monospace';

  @override
  void initState() {
    super.initState();
    parsing = parserWorker.work<HighlightArg, List<Node>?>(
      Runnable(
        fun: _highlightParse,
        arg: HighlightArg(
          source: widget.source,
          language: widget.language,
          autoDetection: widget.autoDetection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var _textStyle = TextStyle(
      fontFamily: _defaultFontFamily,
      color: widget.theme![_rootKey]?.color ?? _defaultFontColor,
    );
    if (widget.textStyle != null) {
      _textStyle = _textStyle.merge(widget.textStyle);
    }

    return Container(
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width.clamp(0, 880)),
      color:
          widget.theme![_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
      padding: widget.padding,
      child: FutureBuilder<List<Node>?>(
        future: parsing,
        // ignore: missing_return
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data;
            if (data != null) {
              return RichText(
                text: TextSpan(
                  style: _textStyle,
                  children: _convert(data),
                ),
              );
            }
          }
          return Text(widget.source, style: _textStyle);
        },
      ),
    );
  }

  static List<Node>? _highlightParse(HighlightArg arg) {
    final res = highlight.parse(
      arg.source,
      language: arg.language,
      autoDetection: arg.autoDetection!,
    );
    return res.nodes;
  }
}

class HighlightArg {
  final String source;
  final String? language;
  final bool? autoDetection;

  HighlightArg({required this.source, this.language, this.autoDetection});
}
