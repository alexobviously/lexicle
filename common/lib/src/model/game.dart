class Game {
  final String? id;
  final String answer;
  final String player;
  final String creator;

  // ignore: unnecessary_this
  Game({this.id, required this.answer, required this.player, String? creator}) : this.creator = creator ?? player;
}
