import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habr_app/routing/routing.dart';
import 'package:habr_app/widgets/widgets.dart';
import '../habr/api.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key key}) : super(key: key);

  @override
  createState() => _SearchPageState();
}

class SearchData {
  String query;
  Order order;

  SearchData({
    @required this.query,
    @required this.order
  });
}

class _SearchPageState extends State<SearchPage> {
  final queryController = TextEditingController();
  ValueNotifier<Order> orderBy = ValueNotifier(Order.Relevance);

  @override
  void dispose() {
    queryController.dispose();
    orderBy.dispose();
    super.dispose();
  }

  void _onSearch() {
    final info = SearchData(query: queryController.text, order: orderBy.value);
    openSearchResult(context, info);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).search),
        actions: [],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: TextFormField(
                      textInputAction: TextInputAction.search,
                      onFieldSubmitted: (_) => _onSearch(),
                      autofocus: true,
                      controller: queryController,
                      decoration: InputDecoration(labelText: AppLocalizations.of(context).keywords),
                    ),
                  )
                ),
                RadioGroup<Order>(
                  groupValue: orderBy,
                  title: AppLocalizations.of(context).sort,
                  enumToText: {
                    Order.Relevance: AppLocalizations.of(context).relevance,
                    Order.Date: AppLocalizations.of(context).date,
                    Order.Rating: AppLocalizations.of(context).rating,
                  },
                ),
              ],
            )
          ),
          Container(
            padding: EdgeInsets.all(5),
            child: SearchButton(onPressed: _onSearch)
          ),
        ]
      )
    );
  }
}

class RadioGroup<Enum> extends StatelessWidget {
  final Map<Enum, String> enumToText;
  final ValueNotifier<Enum> groupValue;
  final String title;

  RadioGroup({
    this.title,
    @required this.groupValue,
    @required this.enumToText});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ValueListenableBuilder<Enum>(
        valueListenable: groupValue,
        builder: (context, group, child) {
          return Column(
            children: [
              ListTile(
                leading: Text(title),
                trailing: Icon(Icons.sort),
              )
            ]..addAll(enumToText.keys.map<Widget>(
                    (e) => RadioListTile(
                      title: Text(enumToText[e]),
                      // activeColor: Colors.blueGrey,
                      value: e,
                      groupValue: group,
                      onChanged: (value) { groupValue.value = value; },
                    )
            ))
          );
        },
      )
    );
  }

}
