import 'dart:convert';

import 'package:common/common.dart';

void main(List<String> args) {
  final json =
      '{"id":"61ee40fe07b9759e63a05962","a":"*****","p":"player","c":"player","g":[{"w":"belts","c":[0],"s":[4]},{"w":"brash","c":[0],"s":[2,3]},{"w":"basic","c":[0,1,2,3,4],"s":[]}],"u":{"w":"","c":[],"s":[]},"f":[]}';
  Game g = Game.fromJson(jsonDecode(json));
  print(g);
  print(g.stub);
  print(g.stub.toMap());
}
