import 'package:logging/logging.dart';

import '../shared/enums.dart';
import '../shared/logging.dart';
import 'generator.dart';

void main(List<String> argc) {
  setupLogging();

  Logger logger = Logger("Generator.main");
  DateTime startTime, endTime;

  if (argc.length == 3) {
    int m = int.tryParse(argc[0])!;
    int n = int.tryParse(argc[1])!;
    String difficstr = argc[2];

    Difficulty diffic = (difficstr == "e") ? Difficulty.easy : Difficulty.hard;

    startTime = DateTime.now();
    Generator g = Generator(m, n);
    //one square for left/right top/bottom boundries

    g.generate(diffic);

    endTime = DateTime.now();
    double diff =
        (endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch) /
            1000;
    logger.info("Time to create:\t$diff seconds");
  } else {
    logger.severe(
        "Incorrect number of arguments, expected 3 found ${argc.length}");
  }
}
