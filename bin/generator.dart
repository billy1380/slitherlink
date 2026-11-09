import 'package:logging/logging.dart';

import 'package:slither_links/src/shared/enums.dart';
import 'package:slither_links/src/shared/export.dart';
import 'package:slither_links/src/shared/logging.dart';
import 'package:slither_links/src/generator/generator.dart';

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

    GeneratedPuzzle result = g.generate(diffic);
    Export(result.solution).export();
    Export(result.puzzle).export();

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
