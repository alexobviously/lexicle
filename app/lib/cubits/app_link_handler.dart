import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';

class AppLinkHandler extends Cubit<AppLinkData> {
  late AppLinks _appLinks;
  AppLinkHandler() : super(AppLinkData.none()) {
    init();
  }

  void init() async {
    print('init AppLinkHandler');
    _appLinks = AppLinks(
      onAppLink: (Uri uri, String stringUri) {
        print('onAppLink: $stringUri');
        // openAppLink(uri);
        _handleLink(stringUri);
      },
    );

    print('#### get initial pre');
    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null && appLink.hasFragment && appLink.fragment != '/') {
      print('getInitialAppLink: ${appLink.toString()}');
      // openAppLink(appLink);
      _handleLink(appLink.toString());
    }
    print('#### get initial post');
  }

  void _handleLink(String link) {
    List<String> parts = link.split('/');
    String data = parts.removeLast();
    String type = parts.removeLast();
    switch (type) {
      case 'invite':
        emit(AppLinkData(type: AppLinkType.groupInvite, data: data));
        break;
      default:
        break;
    }
  }

  void clear() => emit(AppLinkData.none());
}

class AppLinkData {
  final AppLinkType? type;
  final String? data;
  bool get hasLink => type != null;
  AppLinkData({this.type, this.data});
  factory AppLinkData.none() => AppLinkData();
  @override
  String toString() => 'AppLinkData(${type?.name}, $data)';
}

enum AppLinkType {
  groupInvite,
}
