import 'package:app_links/app_links.dart';
import 'package:bloc/bloc.dart';

class AppLinkHandler extends Cubit<String?> {
  late AppLinks _appLinks;
  AppLinkHandler() : super(null) {
    init();
  }

  void init() async {
    print('init AppLinkHandler');
    _appLinks = AppLinks(
      onAppLink: (Uri uri, String stringUri) {
        print('onAppLink: $stringUri');
        // openAppLink(uri);
        emit(stringUri);
      },
    );

    final appLink = await _appLinks.getInitialAppLink();
    if (appLink != null && appLink.hasFragment && appLink.fragment != '/') {
      print('getInitialAppLink: ${appLink.toString()}');
      // openAppLink(appLink);
      emit(appLink.toString());
    }
  }
}
