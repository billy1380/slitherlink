import 'dart:io';

import 'package:logging/logging.dart';

import 'package:slither_links/src/shared/constants.dart';
import 'package:slither_links/src/shared/export.dart';
import 'package:slither_links/src/shared/grid.dart';
import 'package:slither_links/src/shared/import.dart';
import 'package:slither_links/src/shared/logging.dart';
import 'package:slither_links/src/solver/contradiction.dart';
import 'package:slither_links/src/solver/contradictions.dart';
import 'package:slither_links/src/solver/rule.dart';
import 'package:slither_links/src/solver/rules.dart';
import 'package:slither_links/src/solver/solver.dart';

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
    File file = File(filename);
    if (!file.existsSync()) {
      logger.severe("Unable to open file");
      continue;
    }
    importer.buildLattice(file.readAsLinesSync());

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
