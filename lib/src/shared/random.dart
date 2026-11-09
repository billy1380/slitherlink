import 'dart:math';

GlobalRandom r = GlobalRandom();

class GlobalRandom {
  late final Random r;

  GlobalRandom({
    int? seed,
  }) {
    r = Random(seed ?? DateTime.now().millisecond);
  }

  int nextInt(int max) => r.nextInt(max);
}
