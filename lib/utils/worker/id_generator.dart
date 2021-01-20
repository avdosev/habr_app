class IdGenerator {
  int current = 0;
  IdGenerator();

  int genId() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    current = (current + 1) % (1 << 16);
    final guid = ((currentTime & 0xFFFFFF) << 16) + current;

    return guid;
  }

  int call() => genId();
}