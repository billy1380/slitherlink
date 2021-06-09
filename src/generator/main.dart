import '../shared/enums.dart';
import 'generator.dart';

void main(List<String> argc) {
  DateTime startTime, endTime;

  if (argc.length == 3) {
    int m = int.tryParse(argc[0])!;
    int n = int.tryParse(argc[1])!;
    String difficstr = argc[2];

    Difficulty diffic = (difficstr == "e") ? Difficulty.EASY : Difficulty.HARD;

    startTime = DateTime.now();
    Generator g = Generator(
        m, n, diffic); //one square for left/right top/bottom boundries

    endTime = DateTime.now();
    double diff = endTime.millisecondsSinceEpoch -
        startTime.millisecondsSinceEpoch / 1000;
    print("Time to create:\t$diff seconds");
  } else {
    print("Incorrect number of arguments, expected 3 found ${argc.length}");
  }
}
