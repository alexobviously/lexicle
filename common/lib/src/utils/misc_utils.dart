DateTime now() => DateTime.now();
int nowMs() => DateTime.now().millisecondsSinceEpoch;
DateTime today() {
  final now = DateTime.now().toUtc();
  return DateTime.utc(now.year, now.month, now.day);
}
