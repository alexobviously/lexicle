DateTime now() => DateTime.now();
int nowMs() => DateTime.now().millisecondsSinceEpoch;
DateTime today() {
  DateTime now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day);
}
