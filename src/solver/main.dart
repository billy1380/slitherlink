import 'package:logging/logging.dart';

import '../shared/constants.dart';
import '../shared/export.dart';
import '../shared/grid.dart';
import '../shared/import.dart';
import '../shared/logging.dart';
import 'contradiction.dart';
import 'contradictions.dart';
import 'rule.dart';
import 'rules.dart';
import 'solver.dart';

void main(List<String> argc) {
  setupLogging();

  Logger logger = Logger("Solver.main");
  DateTime startTime, endTime;
  startTime = DateTime.now();

  List<Rule> rules = List<Rule>.generate(numRules, initRules);

  List<Contradiction> contradictions =
      List<Contradiction>.generate(numContradictions, initContradictions);

  List<int> selectedRules = List<int>.filled(numRules - numConstRules, -1);
  for (int i = 0; i < numRules - numConstRules; i++) {
    selectedRules[i] = i;
  }

  for (int i = 0; i < argc.length; i++) {
    String filename = argc[i];
    logger.info("Puzzle: $filename");

    Grid grid = Grid();
    Import importer = Import(grid);
    importer.buildLattice(filename);

    Export exporter = Export(grid);

    Solver solver = Solver(grid, rules, contradictions, selectedRules,
        numRules - numConstRules, 100);
    solver.solve();

    exporter.export();

    if (grid.isSolved) {
      logger.info("Solved");
    } else {
      if (solver.testContradictions()) {
        logger.warning("Invalid puzzle");
      } else if (solver.hasMultipleSolutions) {
        logger.warning("Puzzle has multiple solutions");
      } else {
        logger.severe("Not solved");
      }
    }
  }

  endTime = DateTime.now();
  double diff =
      (endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch) /
          1000;
  logger.info("Total time:\t$diff seconds");
}
