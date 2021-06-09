import '../shared/constants.dart';
import '../shared/export.dart';
import '../shared/grid.dart';
import '../shared/import.dart';
import 'contradiction.dart';
import 'contradictions.dart';
import 'rule.dart';
import 'rules.dart';
import 'solver.dart';

void main(List<String> argv) {
  DateTime startTime, endTime;
  startTime = DateTime.now();

  List<Rule> rules = List.generate(num_rules, initRules);

  List<Contradiction> contradictions =
      List.generate(num_contradictions, initContradictions);

  List<int> selectedRules = List.filled(num_rules - num_const_rules, -1);
  for (int i = 0; i < num_rules - num_const_rules; i++) {
    selectedRules[i] = i;
  }

  for (int i = 1; i < argv.length; i++) {
    String filename = argv[i];
    print("Puzzle: $filename");

    Grid grid = Grid();
    Import importer = Import.file(grid, filename);
    Export exporter = Export(grid);

    Solver solver = Solver(grid, rules, contradictions, selectedRules,
        num_rules - num_const_rules, 100);

    exporter.go();

    if (grid.isSolved()) {
      print("Solved");
    } else {
      if (solver.testContradictions()) {
        print("Invalid puzzle");
      } else if (solver.hasMultipleSolutions()) {
        print("Puzzle has multiple solutions");
      } else {
        print("Not solved");
      }
    }
  }

  endTime = DateTime.now();
  double diff =
      (endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch) /
          1000;
  print("Total time:\t$diff seconds");
}
