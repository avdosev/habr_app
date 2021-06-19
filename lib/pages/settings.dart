import 'package:flutter/material.dart';
import 'package:habr_app/stores/app_settings.dart';
import 'package:habr_app/widgets/dropdown_list_tile.dart';
import 'package:habr_app/widgets/html_elements/highlight_code.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).settings),
        ),
        body: Settings());
  }
}

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    final localizations = AppLocalizations.of(context);
    final themeMode = settings.themeMode;
    final codeThemeMode = settings.codeThemeMode;
    final lightCodeTheme = settings.lightCodeTheme;
    final darkCodeTheme = settings.darkCodeTheme;
    final fontSize = settings.fontSize;
    final TextAlign textAlignArticle = settings.articleTextAlign;
    final TextAlign textAlignComments = settings.commentTextAlign;
    final double lineSpacing = settings.lineSpacing;

    return ListView(
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(localizations.systemTheme),
                secondary: const Icon(Icons.brightness_auto),
                value: themeMode == ThemeMode.system,
                onChanged: (val) {
                  if (val) {
                    settings.themeMode = ThemeMode.system;
                  } else {
                    settings.themeMode = ThemeMode.light;
                  }
                },
              ),
              SwitchListTile(
                title: Text(localizations.darkTheme),
                secondary: const Icon(Icons.brightness_2),
                value: themeMode == ThemeMode.dark,
                onChanged: themeMode != ThemeMode.system
                    ? (val) {
                        if (val) {
                          settings.themeMode = ThemeMode.dark;
                        } else {
                          settings.themeMode = ThemeMode.light;
                        }
                      }
                    : null, // Switch будет неактивен при Null
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.palette),
                title: Text(AppLocalizations.of(context).customization),
              ),
              ListTile(
                // leading: const Icon(Icons.font_download_outlined),
                title: Text(localizations.fontSize),
                subtitle: Row(
                  children: [
                    const Icon(Icons.format_size, size: 15),
                    Expanded(
                      child: Slider(
                        min: 12,
                        max: 23,
                        divisions: 23 - 12,
                        value: fontSize.toDouble(),
                        onChanged: (value) {
                          settings.fontSize = value.roundToDouble();
                        },
                        label: fontSize.toString(),
                        semanticFormatterCallback: (value) =>
                            value.round().toString(),
                      ),
                    ),
                    const Icon(Icons.format_size),
                  ],
                ),
              ),
              DropDownListTile(
                values: {
                  TextAlign.left: AppLocalizations.of(context).left,
                  TextAlign.right: AppLocalizations.of(context).right,
                  TextAlign.center: AppLocalizations.of(context).center,
                  TextAlign.justify: AppLocalizations.of(context).fullWidth,
                },
                leading: const Icon(Icons.format_align_left),
                title: Text("Выравнивание текста в постах"),
                defaultKey: textAlignArticle,
                onChanged: (val) => settings.articleTextAlign = val,
              ),
              DropDownListTile(
                values: {
                  TextAlign.left: AppLocalizations.of(context).left,
                  TextAlign.right: AppLocalizations.of(context).right,
                  TextAlign.center: AppLocalizations.of(context).center,
                  TextAlign.justify: AppLocalizations.of(context).fullWidth,
                },
                leading: const Icon(Icons.format_align_left),
                title: Text("Выравнивание текста в комментариях"),
                defaultKey: textAlignComments,
                onChanged: (val) => settings.commentTextAlign = val,
              ),
              /* TODO:
                    Icons:
                    format_line_spacing
                    format_indent_increase
                     */
              ListTile(
                title: Text(AppLocalizations.of(context).lineSpacing),
                subtitle: Row(
                  children: [
                    const Icon(Icons.format_line_spacing, size: 15),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 2,
                        divisions: 20,
                        value: lineSpacing,
                        onChanged: (value) => settings.lineSpacing = value,
                        label: lineSpacing.toString(),
                        semanticFormatterCallback: (value) =>
                            lineSpacing.toString(),
                      ),
                    ),
                    const Icon(Icons.format_line_spacing),
                  ],
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(AppLocalizations.of(context).customizationCode),
              ),
              SwitchListTile(
                title: Text(localizations.systemTheme),
                secondary: const Icon(Icons.brightness_auto),
                value: codeThemeMode == ThemeMode.system,
                onChanged: (val) {
                  if (val) {
                    settings.codeThemeMode = ThemeMode.system;
                  } else {
                    settings.codeThemeMode = ThemeMode.dark;
                  }
                },
              ),
              SwitchListTile(
                title: Text(localizations.darkTheme),
                secondary: const Icon(Icons.brightness_2),
                value: codeThemeMode == ThemeMode.dark,
                onChanged: codeThemeMode != ThemeMode.system
                    ? (val) {
                        if (val) {
                          settings.codeThemeMode = ThemeMode.dark;
                        } else {
                          settings.codeThemeMode = ThemeMode.light;
                        }
                      }
                    : null, // Switch будет неактивен при Null
              ),
              DropDownListTile(
                values: Map.fromIterables(
                    HighlightCode.themes, HighlightCode.themes),
                title: Text("Стиль темной темы"),
                defaultKey: darkCodeTheme,
                onChanged: (val) => settings.darkCodeTheme = val,
              ),
              DropDownListTile(
                values: Map.fromIterables(
                    HighlightCode.themes, HighlightCode.themes),
                title: Text("Стиль светлой темы"),
                defaultKey: lightCodeTheme,
                onChanged: (val) => settings.lightCodeTheme = val,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
