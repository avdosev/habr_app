import 'package:flutter/material.dart';
import 'package:habr_app/models/post_preview.dart';
import 'package:habr_app/stores/filters_store.dart';
import 'package:habr_app/utils/filters/article_preview_filters.dart';
import 'package:habr_app/utils/log.dart';
import 'package:habr_app/widgets/adaptive_ui.dart';
import 'package:itertools/itertools.dart';
import 'package:hive/hive.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FiltersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.filters),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _createFilterDialog,
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<Box<Filter<PostPreview>>>(
      valueListenable: FiltersStorage().listenable(),
      builder: (context, box, child) => ListView(
        children: box.values
            .mapIndexed<Widget>((i, filter) {
              if (filter is NicknameAuthorFilter) {
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(filter.nickname!),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => FiltersStorage().removeFilterAt(i),
                  ),
                );
              } else if (filter is CompanyNameFilter) {
                return ListTile(
                  leading: const Icon(Icons.groups),
                  title: Text(filter.companyName!),
                  trailing: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => FiltersStorage().removeFilterAt(i),
                  ),
                );
              } else {
                logInfo("filter not supported");
              }
              return null;
            } as Widget Function(int, Filter<PostPreview>))
            .map((e) => DefaultConstraints(child: e))
            .toList(),
      ),
    );
  }

  Future<void> _createFilterDialog() async {
    final type = await showDialog<_DialogType>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context)!.createFilterBy),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, _DialogType.AuthorNickname);
                },
                child: Text(AppLocalizations.of(context)!.authorNicknameFilter),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, _DialogType.CompanyName);
                },
                child: Text(AppLocalizations.of(context)!.companyNameFilter),
              ),
            ],
          );
        });

    if (type == null) return;

    switch (type) {
      case _DialogType.AuthorNickname:
        await _createAuthorNicknameFilter();
        break;
      case _DialogType.CompanyName:
        await _createCompanyNameFilter();
        break;
      default:
        logInfo('$type not supported');
    }
  }

  Future<void> _createAuthorNicknameFilter() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return _AuthorNicknameFilterDialog();
        });
  }

  Future<void> _createCompanyNameFilter() async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return _CompanyNameFilterDialog();
        });
  }
}

enum _DialogType {
  AuthorNickname,
  CompanyName,
  Rating,
  // other
}

class _AuthorNicknameFilterDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AuthorNicknameFilterDialogState();
}

class _AuthorNicknameFilterDialogState
    extends State<_AuthorNicknameFilterDialog> {
  TextEditingController? nickanameControll;

  @override
  void initState() {
    super.initState();
    nickanameControll = TextEditingController();
  }

  bool nicknameValid() {
    return nickanameControll!.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nickanameControll,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.authorNickname,
                hintText: AppLocalizations.of(context)!.authorNicknameHint,
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context);
            }),
        TextButton(
            child: Text(AppLocalizations.of(context)!.create),
            onPressed: () {
              if (nicknameValid())
                FiltersStorage()
                    .addFilter(NicknameAuthorFilter(nickanameControll!.text));
              Navigator.pop(context);
            })
      ],
    );
  }
}

class _CompanyNameFilterDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CompanyNameFilterDialogState();
}

class _CompanyNameFilterDialogState extends State<_CompanyNameFilterDialog> {
  TextEditingController? nickanameControll;

  @override
  void initState() {
    super.initState();
    nickanameControll = TextEditingController();
  }

  bool nicknameValid() {
    return nickanameControll!.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16.0),
      content: Row(
        children: [
          Expanded(
            child: TextField(
              controller: nickanameControll,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Имя компании",
                hintText: "Например, RUVDS.com",
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context);
            }),
        TextButton(
            child: Text(AppLocalizations.of(context)!.create),
            onPressed: () {
              if (nicknameValid())
                FiltersStorage()
                    .addFilter(CompanyNameFilter(nickanameControll!.text));
              Navigator.pop(context);
            })
      ],
    );
  }
}
