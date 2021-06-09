import '../shared/constants.dart';
import '../shared/enums.dart';
import '../shared/grid.dart';
import '../shared/structs.dart';
import 'contradiction.dart';
import 'epq.dart';
import 'rotate.dart';
import 'rule.dart';

const int max_depth = 100;

class Solver {
  Grid grid_;
  int depth_;
  List<Rule> rules_;
  List<int> selectedRules_;
  late int selectLength_;
  List<Contradiction> contradictions_;
  EPQ epq_ = EPQ();
  late int epqSize_;
  bool multipleSolutions_;
  int ruleCounts_;

  bool hasMultipleSolutions() {
    return multipleSolutions_;
  }

/* Constructor takes a grid as input to solve */
  Solver(this.grid_, this.rules_, this.contradictions_, this.selectedRules_,
      int selectLength, this.depth_)
      : multipleSolutions_ = false,
        ruleCounts_ = 0 {
    epq_.initEPQ(grid_.getHeight(), grid_.getWidth());

    List<int> selectedPlusBasic = List.generate(selectLength + num_const_rules,
        (i) => i < selectedRules_.length ? selectedRules_[i] : -1);

    for (int i = 1; i <= num_const_rules; i++) {
      selectedPlusBasic[selectLength + num_const_rules - i] = (num_rules - i);
    }

    selectLength_ = selectLength + num_const_rules;
    _applyRules(selectedPlusBasic);
    selectLength_ = selectLength;

    _solve();
  }

/* Constructor for when the EPQ should be passed down. */
  Solver.oldEpq(this.grid_, this.rules_, this.contradictions_,
      this.selectedRules_, this.selectLength_, this.depth_, EPQ oldEPQ)
      : multipleSolutions_ = false,
        ruleCounts_ = 0 {
    epq_.copyPQ(oldEPQ);

    _solve();
  }

  void resetSolver() {
    grid_.resetGrid();
    multipleSolutions_ = false;
  }

/* Runs a loop testing each contradiction in each orientation in
 * each valid position on the grid, checking if the contradiction
 * applies, and, if so, returning true. */
  bool testContradictions() {
    if (grid_.containsClosedContours() && !grid_.isSolved()) {
      return true;
    }
    for (int i = 0; i < grid_.getHeight(); i++) {
      for (int j = 0; j < grid_.getWidth(); j++) {
        if (grid_.getContraMatrix(i, j)) {
          for (int x = 0; x < num_contradictions; x++) {
            for (Orientation orient in [
              Orientation.UP,
              Orientation.DOWN,
              Orientation.LEFT,
              Orientation.RIGHT,
              Orientation.UPFLIP,
              Orientation.DOWNFLIP,
              Orientation.LEFTFLIP,
              Orientation.RIGHTFLIP
            ]) {
              if (_contradictionApplies(i, j, contradictions_[x], orient)) {
                return true;
              }
            }
          }
          grid_.setContraMatrix(i, j, false);
        }
      }
    }

    return false;
  }

/* Apply a combination of deterministic rules and
 * recursive guessing to find a solution to a puzzle */
  void _solve() {
    grid_.setUpdated(true);
    while (grid_.getUpdated() && !grid_.isSolved()) {
      _applyRules(selectedRules_);

      for (int d = 0; d < depth_; d++) {
        if (!grid_.getUpdated() &&
            !testContradictions() &&
            !grid_.isSolved() &&
            !multipleSolutions_) {
          _solveDepth(d);
        }
      }
    }
  }

/* */
  void _updateEPQ() {
    epq_.empty();

    int m = grid_.getHeight();
    int n = grid_.getWidth();
    for (int i = 1; i < m; i++) {
      for (int j = 1; j < n - 1; j++) {
        if (grid_.getHLine(i, j) != Edge.EMPTY) {
          continue;
        }
        double prio = (grid_.getHLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i, j + 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i + 1, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i - 1, j + 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i, j + 1) != Edge.EMPTY ? 1 : 0);

        if (prio > 0) {
          epq_.emplace(prio, i, j, true);
        }
      }
    }

    for (int i = 1; i < m - 1; i++) {
      for (int j = 1; j < n; j++) {
        if (grid_.getVLine(i, j) != Edge.EMPTY) {
          continue;
        }
        double prio = (grid_.getVLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i + 1, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getVLine(i, j + 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i + 1, j - 1) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i, j) != Edge.EMPTY ? 1 : 0) +
            (grid_.getHLine(i + 1, j) != Edge.EMPTY ? 1 : 0);

        if (prio > 0) {
          epq_.emplace(prio, i, j, false);
        }
      }
    }
    epqSize_ = epq_.size();
  }

  bool get _upq => true;

/* Make a guess in each valid position in the graph */
  void _solveDepth(int depth) {
    bool usingPrioQueue = _upq;

    if (usingPrioQueue) {
      int initSize = epq_.size();
      int guesses = 0;

      while (!epq_.empty() && guesses++ < initSize && !multipleSolutions_) {
        PrioEdge pe = epq_.top();

        if (pe.h) {
          _makeHLineGuess(pe.coords.i, pe.coords.j, depth);
          if (grid_.getHLine(pe.coords.i, pe.coords.j) == Edge.EMPTY) {
            pe.priority = pe.priority - 1;
            epq_.push(pe);
          }
          if (grid_.getUpdated()) {
            break;
          }
        } else {
          _makeVLineGuess(pe.coords.i, pe.coords.j, depth);
          if (grid_.getVLine(pe.coords.i, pe.coords.j) == Edge.EMPTY) {
            pe.priority = pe.priority - 1;
            epq_.push(pe);
          }
          if (grid_.getUpdated()) {
            break;
          }
        }
        epq_.pop();
      }
    } else {
      for (int i = 0; i < grid_.getHeight() + 1; i++) {
        for (int j = 0; j < grid_.getWidth(); j++) {
          _applyRules(selectedRules_);
          _makeHLineGuess(i, j, depth);
        }
      }

      for (int i = 0; i < grid_.getHeight(); i++) {
        for (int j = 0; j < grid_.getWidth() + 1; j++) {
          _applyRules(selectedRules_);
          _makeVLineGuess(i, j, depth);
        }
      }
    }
  }

/* Horizontal guess at the given location to the given depth */
  void _makeHLineGuess(int i, int j, int depth) {
    assert(
        0 <= i && i < grid_.getHeight() + 1 && 0 <= j && j < grid_.getWidth());
    assert(depth >= 0);

    if (grid_.getHLine(i, j) == Edge.EMPTY) {
      /* there is only one case where the grid
         * will not be updated, which is handled
         * at the end of this iteration. */
      grid_.setUpdated(true);

      Grid lineGuess = Grid();
      grid_.copy(lineGuess);

      /* make a LINE guess */
      lineGuess.setHLine(i, j, Edge.LINE);
      Solver lineSolver = Solver.oldEpq(lineGuess, rules_, contradictions_,
          selectedRules_, selectLength_, depth, epq_);
      ruleCounts_ = ruleCounts_ + lineSolver.ruleCounts_;

      /* If this guess happens to solve the puzzle we need to make sure that
         * the opposite guess leads to a contradiction, otherwise we know that
         * there might be multiple solutions */
      if (lineGuess.isSolved()) {
        Grid nLineGuess = Grid();
        grid_.copy(nLineGuess);
        nLineGuess.setHLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, rules_, contradictions_,
            selectedRules_, selectLength_, max_depth, epq_);
        ruleCounts_ = ruleCounts_ + nLineSolver.ruleCounts_;
        if (nLineSolver.testContradictions()) {
          /* The opposite guess leads to a contradiction
                 * so the previous found solution is the only one */
          lineGuess.copy(grid_);
        } else if (nLineGuess.isSolved() ||
            nLineSolver.hasMultipleSolutions()) {
          /* The opposite guess also led to a solution
                 * so there are multiple solutions */
          multipleSolutions_ = true;
        } else {
          /* The opposite guess led to neither a solution or
                 * a contradiction, which can only happen if the subPuzzle
                 * is unsolvable for our maximum depth. We can learn nothing
                 * from this result. */
          grid_.setUpdated(false);
        }
        return;
      }
      /* test for contradictions; if we encounter one we set the opposite line */
      else if (lineSolver.testContradictions()) {
        grid_.setHLine(i, j, Edge.NLINE);
        return;
      } else {
        Grid nLineGuess = Grid();
        grid_.copy(nLineGuess);

        /* make an NLINE guess */
        nLineGuess.setHLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, rules_, contradictions_,
            selectedRules_, selectLength_, depth, epq_);
        ruleCounts_ = ruleCounts_ + nLineSolver.ruleCounts_;

        /* if both guesses led to multiple solutions, we know this puzzle
             * must also lead to another solution */
        if (nLineSolver.hasMultipleSolutions() ||
            lineSolver.hasMultipleSolutions()) {
          multipleSolutions_ = true;
          return;
        }
        /* again check if solved. In this case we already know that we can't
             * get to a solution or contradiction with the opposite guess, so
             * we know we can't conclude whether this is the single solution */
        else if (nLineGuess.isSolved()) {
          lineSolver = Solver.oldEpq(lineGuess, rules_, contradictions_,
              selectedRules_, selectLength_, max_depth, epq_);
          ruleCounts_ = ruleCounts_ + lineSolver.ruleCounts_;
          if (lineSolver.testContradictions()) {
            /* The opposite guess leads to a contradiction
                     * so the previous found solution is the only one */
            nLineGuess.copy(grid_);
          } else if (lineGuess.isSolved() ||
              lineSolver.hasMultipleSolutions()) {
            /* The opposite guess also led to a solution
                     * so there are multiple solutions */
            multipleSolutions_ = true;
          } else {
            /* The opposite guess led to neither a solution or
                     * a contradiction, which can only happen if the subPuzzle
                     * is unsolvable for our maximum depth. We can learn nothing
                     * from this result. */
            grid_.setUpdated(false);
          }
          return;
        }
        /* again check for contradictions */
        else if (nLineSolver.testContradictions()) {
          grid_.setHLine(i, j, Edge.LINE);
          return;
        } else {
          grid_.setUpdated(false);

          /* check for things that happen when we make both
                 * guesses; if we find any, we know they must happen */
          _intersectGrids(lineGuess, nLineGuess);

          if (grid_.getUpdated()) {
            return;
          }
        }
      }
    }
  }

/* Vertical guess at the given location to the given depth */
  void _makeVLineGuess(int i, int j, int depth) {
    assert(
        0 <= i && i < grid_.getHeight() && 0 <= j && j < grid_.getWidth() + 1);
    assert(depth >= 0);

    if (grid_.getVLine(i, j) == Edge.EMPTY) {
      /* there is only one case where the grid
         * will not be updated, which is handled
         * at the end of this iteration. */
      grid_.setUpdated(true);

      Grid lineGuess = Grid();
      grid_.copy(lineGuess);

      /* make a LINE guess */
      lineGuess.setVLine(i, j, Edge.LINE);
      Solver lineSolver = Solver.oldEpq(lineGuess, rules_, contradictions_,
          selectedRules_, selectLength_, depth, epq_);
      ruleCounts_ = ruleCounts_ + lineSolver.ruleCounts_;

      /* If this guess happens to solve the puzzle we need to make sure that
         * the opposite guess leads to a contradiction, otherwise we know that
         * there might be multiple solutions */
      if (lineGuess.isSolved()) {
        Grid nLineGuess = Grid();
        grid_.copy(nLineGuess);
        nLineGuess.setVLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, rules_, contradictions_,
            selectedRules_, selectLength_, max_depth, epq_);
        ruleCounts_ = ruleCounts_ + nLineSolver.ruleCounts_;
        if (nLineSolver.testContradictions()) {
          /* The opposite guess leads to a contradiction
                 * so the previous found solution is the only one */
          lineGuess.copy(grid_);
        } else if (nLineGuess.isSolved() ||
            nLineSolver.hasMultipleSolutions()) {
          /* The opposite guess also led to a solution
                 * so there are multiple solutions */
          multipleSolutions_ = true;
        } else {
          /* The opposite guess led to neither a solution or
                 * a contradiction, which can only happen if the subPuzzle
                 * is unsolvable for our maximum depth. We can learn nothing
                 * from this result. */
          grid_.setUpdated(false);
        }
        return;
      }
      /* test for contradictions; if we encounter one we set the opposite line */
      else if (lineSolver.testContradictions()) {
        grid_.setVLine(i, j, Edge.NLINE);
        return;
      } else {
        Grid nLineGuess = Grid();
        grid_.copy(nLineGuess);

        /* make an NLINE guess */
        nLineGuess.setVLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, rules_, contradictions_,
            selectedRules_, selectLength_, depth, epq_);
        ruleCounts_ = ruleCounts_ + nLineSolver.ruleCounts_;

        /* if both guesses led to multiple solutions, we know this puzzle
             * must also lead to another solution */
        if (nLineSolver.hasMultipleSolutions() ||
            lineSolver.hasMultipleSolutions()) {
          multipleSolutions_ = true;
          return;
        }
        /* again check if solved. In this case we already know that we can't
             * get to a solution or contradiction with the opposite guess, so
             * we know we can't conclude whether this is the single solution */
        else if (nLineGuess.isSolved()) {
          lineSolver = Solver.oldEpq(lineGuess, rules_, contradictions_,
              selectedRules_, selectLength_, max_depth, epq_);
          ruleCounts_ = ruleCounts_ + lineSolver.ruleCounts_;
          if (lineSolver.testContradictions()) {
            /* The opposite guess leads to a contradiction
                     * so the previous found solution is the only one */
            nLineGuess.copy(grid_);
          } else if (lineGuess.isSolved() ||
              lineSolver.hasMultipleSolutions()) {
            /* The opposite guess also led to a solution
                     * so there are multiple solutions */
            multipleSolutions_ = true;
          } else {
            /* The opposite guess led to neither a solution or
                     * a contradiction, which can only happen if the subPuzzle
                     * is unsolvable for our maximum depth. We can learn nothing
                     * from this result. */
            grid_.setUpdated(false);
          }
          return;
        }
        /* again check for contradictions */
        else if (nLineSolver.testContradictions()) {
          grid_.setVLine(i, j, Edge.LINE);
          return;
        } else {
          grid_.setUpdated(false);

          /* check for things that happen when we make both
                 * guesses; if we find any, we know they must happen */
          _intersectGrids(lineGuess, nLineGuess);

          if (grid_.getUpdated()) {
            return;
          }
        }
      }
    }
  }

/* Checks for the intersection between lineGuess and nLineGuess grids
 * and applies any intersection to the canonical grid. */
  void _intersectGrids(Grid lineGuess, Grid nLineGuess) {
    assert(lineGuess.getHeight() == nLineGuess.getHeight() &&
        lineGuess.getWidth() == nLineGuess.getWidth());

    for (int i = 0; i < grid_.getHeight() + 1; i++) {
      for (int j = 0; j < grid_.getWidth(); j++) {
        if (lineGuess.getHLine(i, j) == nLineGuess.getHLine(i, j) &&
            lineGuess.getHLine(i, j) != grid_.getHLine(i, j)) {
          grid_.setHLine(i, j, lineGuess.getHLine(i, j));
          grid_.setUpdated(true);
        }
      }
    }

    for (int i = 0; i < grid_.getHeight(); i++) {
      for (int j = 0; j < grid_.getWidth() + 1; j++) {
        if (lineGuess.getVLine(i, j) == nLineGuess.getVLine(i, j) &&
            lineGuess.getVLine(i, j) != grid_.getVLine(i, j)) {
          grid_.setVLine(i, j, lineGuess.getVLine(i, j));
          grid_.setUpdated(true);
        }
      }
    }
  }

/* Runs a loop checking each rule in each orientation in each valid
 * position on the grid, checking if the rule applies, and, if so,
 * applying it, and continue updating them until there are no longer
 * any changes being made. */
  void _applyRules(List<int> selectedRules) {
    while (grid_.getUpdated()) {
      grid_.setUpdated(false);
      for (int i = 0; i < grid_.getHeight(); i++) {
        for (int j = 0; j < grid_.getWidth(); j++) {
          if (grid_.getUpdateMatrix(i, j)) {
            for (int x = 0; x < selectLength_; x++) {
              for (Orientation orient in [
                Orientation.UP,
                Orientation.DOWN,
                Orientation.LEFT,
                Orientation.RIGHT,
                Orientation.UPFLIP,
                Orientation.DOWNFLIP,
                Orientation.LEFTFLIP,
                Orientation.RIGHTFLIP
              ]) {
                if (_ruleApplies(i, j, rules_[selectedRules[x]], orient)) {
                  _applyRule(i, j, rules_[selectedRules[x]], orient);
                }
              }
            }
          }
          grid_.setUpdateMatrix(i, j, false);
        }
      }
    }
  }

/* Applies a rule in a given orientation to a given region of the
 * grid, overwriting all old values with any applicable values from
 * the after_ lattice for that rule. */
  void _applyRule(int i, int j, Rule rule, Orientation orient) {
    int m = rule.getHeight();
    int n = rule.getWidth();

    List<EdgePosition> hLineDiff = rule.getHLineDiff();
    for (int k = 0; k < hLineDiff.length; k++) {
      EdgePosition pattern = hLineDiff[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (grid_.getHLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            grid_.setValid(
                grid_.setHLine(adjusted.i + i, adjusted.j + j, pattern.edge));
            grid_.setUpdated(true);
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (grid_.getVLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            grid_.setValid(
                grid_.setVLine(adjusted.i + i, adjusted.j + j, pattern.edge));
            grid_.setUpdated(true);
          }
          break;
      }
    }

    List<EdgePosition> vLineDiff = rule.getVLineDiff();
    for (int k = 0; k < vLineDiff.length; k++) {
      EdgePosition pattern = vLineDiff[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (grid_.getVLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            grid_.setValid(
                grid_.setVLine(adjusted.i + i, adjusted.j + j, pattern.edge));
            grid_.setUpdated(true);
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (grid_.getHLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            grid_.setValid(
                grid_.setHLine(adjusted.i + i, adjusted.j + j, pattern.edge));
            grid_.setUpdated(true);
          }
          break;
      }
    }
  }

/* Checks if a rule in a given orientation applies to a given
 * region of the grid by checking all non-empty values in the
 * before_ lattice and verifying they correspond to the values
 * in the grid. */
  bool _ruleApplies(int i, int j, Rule rule, Orientation orient) {
    int m = rule.getHeight();
    int n = rule.getWidth();
    if (i > grid_.getHeight() - rule.getNumberHeight(orient) ||
        j > grid_.getWidth() - rule.getNumberWidth(orient)) {
      return false;
    }

    List<NumberPosition> numberPattern = rule.getNumberPattern();
    for (int k = 0; k < numberPattern.length; k++) {
      NumberPosition pattern = numberPattern[k];
      Coordinates adjusted =
          rotateNumber(pattern.coords.i, pattern.coords.j, m, n, orient);

      if (pattern.num != grid_.getNumber(adjusted.i + i, adjusted.j + j)) {
        return false;
      }
    }

    List<EdgePosition> hLinePattern = rule.getHLinePattern();
    for (int k = 0; k < hLinePattern.length; k++) {
      EdgePosition pattern = hLinePattern[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != grid_.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != grid_.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    List<EdgePosition> vLinePattern = rule.getVLinePattern();
    for (int k = 0; k < vLinePattern.length; k++) {
      EdgePosition pattern = vLinePattern[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != grid_.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != grid_.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    return true;
  }

/* Checks if a contradiction in a given orientation applies to
 * a given region of the grid by checking all non-empty values
 * in the before_ lattice and verifying they correspond to the
 * values in the grid. */
  bool _contradictionApplies(
      int i, int j, Contradiction contradiction, Orientation orient) {
    int m = contradiction.getHeight();
    int n = contradiction.getWidth();

    if (i > grid_.getHeight() - contradiction.getNumberHeight(orient) ||
        j > grid_.getWidth() - contradiction.getNumberWidth(orient)) {
      return false;
    }

    List<NumberPosition> numberPattern = contradiction.getNumberPattern();
    for (int k = 0; k < numberPattern.length; k++) {
      NumberPosition pattern = numberPattern[k];
      Coordinates adjusted =
          rotateNumber(pattern.coords.i, pattern.coords.j, m, n, orient);

      if (pattern.num != grid_.getNumber(adjusted.i + i, adjusted.j + j)) {
        return false;
      }
    }

    List<EdgePosition> hLinePattern = contradiction.getHLinePattern();
    for (int k = 0; k < hLinePattern.length; k++) {
      EdgePosition pattern = hLinePattern[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != grid_.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != grid_.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    List<EdgePosition> vLinePattern = contradiction.getVLinePattern();
    for (int k = 0; k < vLinePattern.length; k++) {
      EdgePosition pattern = vLinePattern[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != grid_.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != grid_.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    return true;
  }
}
