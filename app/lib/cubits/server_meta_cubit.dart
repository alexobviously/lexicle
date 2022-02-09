import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:word_game/model/server_meta.dart';
import 'package:word_game/services/api_client.dart';

class ServerMetaCubit extends Cubit<ServerMeta> {
  ServerMetaCubit() : super(ServerMeta.initial()) {
    getMeta();
  }

  void getMeta() async {
    final result = await ApiClient.getMeta();
    if (result.ok) {
      emit(result.object!);
    } else {
      Timer(Duration(seconds: 10), () => getMeta());
    }
  }
}
