import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:word_game/ui/standard_scaffold.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return StandardScaffold(
      title: 'Settings',
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Text('nothing here yet'),
              Spacer(),
              _version(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _version() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Version ${snapshot.data!.version}'),
              ),
            ],
          );
        } else {
          return Text('Version...');
        }
      },
    );
  }
}
