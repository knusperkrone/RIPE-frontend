import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripe/ui/component/branded.dart';
import 'package:tuple/tuple.dart';

import 'agent_config_decorator.dart';

class AgentConfigPage extends StatefulWidget {
  final String domain;
  final Future<Map<String, Tuple2<String, Map<String, dynamic>>>?>
      configRequest;

  const AgentConfigPage(this.domain, this.configRequest);

  @override
  State<StatefulWidget> createState() => AgentConfigPageState();
}

class AgentConfigPageState extends State<AgentConfigPage> {
  Map<String, Tuple2<String, Map<String, dynamic>>>? config;
  List<GlobalKey<AgentConfigDecoratorState>>? widgetKeys;

  @override
  void initState() {
    super.initState();
    widget.configRequest.then((value) {
      if (value == null) {
        final snackbar = RipeSnackbar(
          context,
          label: 'Einstellungen konnten nicht geladen werden',
          duration: const Duration(seconds: 60),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () => Navigator.pop(context),
          ),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
        return;
      }

      widgetKeys = List.generate(value.length, (_) => GlobalKey());
      setState(() => config = value);
    });
  }

  Future<void> _onSubmit() async {
    if (widgetKeys == null || config == null) {
      return;
    }

    int i = 0;
    final transformed = config!.map<String, dynamic>((key, value) {
      final dynamic newValue = widgetKeys![i++].currentState!.getJsonValue();
      return MapEntry<String, dynamic>(key, newValue);
    });

    Navigator.pop(context, transformed);
  }

  @override
  Widget build(BuildContext context) {
    String title = widget.domain;
    if (title.contains('_')) {
      title = title.substring(min(title.length, title.indexOf('_') + 1));
    }

    return Scaffold(body: Builder(builder: (context) {
      return Scaffold(
        appBar: RipeAppBar(
          title: Text('$title Einstellungen'),
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: _onSubmit,
          child: const Icon(Icons.check, color: Colors.white),
          hoverElevation: 0.0,
        ),
      );
    }));
  }

  Widget _buildBody() {
    if (config == null) {
      return Container();
    }

    return ListView.builder(
      itemCount: config!.keys.length,
      itemBuilder: (context, i) {
        final key = config!.keys.skip(i).first;
        final tuple = config![key]!;
        final name = tuple.item1;
        final json = tuple.item2;

        final decorator = AgentConfigDecorator.fromJson(widgetKeys![i], json);
        final pos = decorator.position;

        if (pos == DecoratorPosition.BELOW) {
          return new Card(
              child: Column(
            children: [
              Padding(child: Text(name), padding: const EdgeInsets.all(5)),
              decorator
            ],
          ));
        }
        return new Card(
          elevation: 0.5,
          child: ListTile(
            leading: Text(name),
            trailing: pos == DecoratorPosition.TRAILING ? decorator : null,
            title: pos == DecoratorPosition.TITLE ? decorator : null,
          ),
        );
      },
    );
  }
}
