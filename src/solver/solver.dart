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
  final Grid _grid;
  final int _depth;
  final List<Rule> _rules;
  final List<int> _selectedRules;
  late int _selectLength;
  final List<Contradiction> _contradictions;
  final EPQ _epq = EPQ();

  bool _multipleSolutions;
  int _ruleCounts;

  bool get hasMultipleSolutions {
    return _multipleSolutions;
  }

/* Constructor takes a grid as input to solve */
  Solver(this._grid, this._rules, this._contradictions, this._selectedRules,
      int selectLength, this._depth)
      : _multipleSolutions = false,
        _ruleCounts = 0 {
    _epq.initEPQ(_grid.height, _grid.width);

    List<int> selectedPlusBasic = List<int>.generate(
        selectLength + num_const_rules,
        (int i) => i < _selectedRules.length ? _selectedRules[i] : -1);

    for (int i = 1; i <= num_const_rules; i++) {
      selectedPlusBasic[selectLength + num_const_rules - i] = (num_rules - i);
    }

    _selectLength = selectLength + num_const_rules;
    _applyRules(selectedPlusBasic);
    _selectLength = selectLength;
  }

/* Constructor for when the EPQ should be passed down. */
  Solver.oldEpq(this._grid, this._rules, this._contradictions,
      this._selectedRules, this._selectLength, this._depth, EPQ oldEPQ)
      : _multipleSolutions = false,
        _ruleCounts = 0 {
    _epq.copyPQ(oldEPQ);
  }

  void resetSolver() {
    _grid.resetGrid();
    _multipleSolutions = false;
  }

/* Runs a loop testing each contradiction in each orientation in
 * each valid position on the grid, checking if the contradiction
 * applies, and, if so, returning true. */
  bool testContradictions() {
    if (_grid.containsClosedContours && !_grid.isSolved) {
      return true;
    }

    for (int i = 0; i < _grid.height; i++) {
      for (int j = 0; j < _grid.width; j++) {
        if (_grid.getContraMatrix(i, j)) {
          for (int x = 0; x < num_contradictions; x++) {
            for (Orientation orient in Orientation.values) {
              if (_contradictionApplies(i, j, _contradictions[x], orient)) {
                return true;
              }
            }
          }
          _grid.setContraMatrix(i, j, false);
        }
      }
    }

    return false;
  }

/* Apply a combination of deterministic rules and
 * recursive guessing to find a solution to a puzzle */
  void solve() {
    _grid.updated = true;
    while (_grid.updated && !_grid.isSolved) {
      _applyRules(_selectedRules);

      for (int d = 0; d < _depth; d++) {
        if (!_grid.updated &&
            !testContradictions() &&
            !_grid.isSolved &&
            !_multipleSolutions) {
          _solveDepth(d);
        }
      }
    }
  }

  // void _updateEPQ() {
  //   epq_.isEmpty;

  //   int m = grid_.height;
  //   int n = grid_.width;
  //   for (int i = 1; i < m; i++) {
  //     for (int j = 1; j < n - 1; j++) {
  //       if (grid_.getHLine(i, j) != Edge.EMPTY) {
  //         continue;
  //       }
  //       double prio = (grid_.getHLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i, j + 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i + 1, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i - 1, j + 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i, j + 1) != Edge.EMPTY ? 1 : 0);

  //       if (prio > 0) {
  //         epq_.emplace(prio, i, j, true);
  //       }
  //     }
  //   }

  //   for (int i = 1; i < m - 1; i++) {
  //     for (int j = 1; j < n; j++) {
  //       if (grid_.getVLine(i, j) != Edge.EMPTY) {
  //         continue;
  //       }
  //       double prio = (grid_.getVLine(i - 1, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i + 1, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getVLine(i, j + 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i, j - 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i + 1, j - 1) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i, j) != Edge.EMPTY ? 1 : 0) +
  //           (grid_.getHLine(i + 1, j) != Edge.EMPTY ? 1 : 0);

  //       if (prio > 0) {
  //         epq_.emplace(prio, i, j, false);
  //       }
  //     }
  //   }
  //   epqSize_ = epq_.size;
  // }

  bool get _upq => true;

/* Make a guess in each valid position in the graph */
  void _solveDepth(int depth) {
    bool usingPrioQueue = _upq;

    if (usingPrioQueue) {
      int initSize = _epq.size;
      int guesses = 0;

      while (!_epq.isEmpty && guesses++ < initSize && !_multipleSolutions) {
        PrioEdge pe = _epq.top();

        if (pe.h) {
          _makeHLineGuess(pe.coords.i, pe.coords.j, depth);
          if (_grid.getHLine(pe.coords.i, pe.coords.j) == Edge.EMPTY) {
            pe.priority = pe.priority - 1;
            _epq.push(pe);
          }
          if (_grid.updated) {
            break;
          }
        } else {
          _makeVLineGuess(pe.coords.i, pe.coords.j, depth);
          if (_grid.getVLine(pe.coords.i, pe.coords.j) == Edge.EMPTY) {
            pe.priority = pe.priority - 1;
            _epq.push(pe);
          }
          if (_grid.updated) {
            break;
          }
        }
        _epq.pop();
      }
    } else {
      for (int i = 0; i < _grid.height + 1; i++) {
        for (int j = 0; j < _grid.width; j++) {
          _applyRules(_selectedRules);
          _makeHLineGuess(i, j, depth);
        }
      }

      for (int i = 0; i < _grid.height; i++) {
        for (int j = 0; j < _grid.width + 1; j++) {
          _applyRules(_selectedRules);
          _makeVLineGuess(i, j, depth);
        }
      }
    }
  }

/* Horizontal guess at the given location to the given depth */
  void _makeHLineGuess(int i, int j, int depth) {
    assert(0 <= i && i < _grid.height + 1 && 0 <= j && j < _grid.width);
    assert(depth >= 0);

    if (_grid.getHLine(i, j) == Edge.EMPTY) {
      /* there is only one case where the grid
         * will not be updated, which is handled
         * at the end of this iteration. */
      _grid.updated = true;

      Grid lineGuess = Grid();
      _grid.copy(lineGuess);

      /* make a LINE guess */
      lineGuess.setHLine(i, j, Edge.LINE);

      Solver lineSolver = Solver.oldEpq(lineGuess, _rules, _contradictions,
          _selectedRules, _selectLength, depth, _epq);
      lineSolver.solve();

      _ruleCounts = _ruleCounts + lineSolver._ruleCounts;

      /* If this guess happens to solve the puzzle we need to make sure that
         * the opposite guess leads to a contradiction, otherwise we know that
         * there might be multiple solutions */
      if (lineGuess.isSolved) {
        Grid nLineGuess = Grid();
        _grid.copy(nLineGuess);
        nLineGuess.setHLine(i, j, Edge.NLINE);

        Solver nLineSolver = Solver.oldEpq(nLineGuess, _rules, _contradictions,
            _selectedRules, _selectLength, max_depth, _epq);
        nLineSolver.solve();

        _ruleCounts = _ruleCounts + nLineSolver._ruleCounts;
        if (nLineSolver.testContradictions()) {
          /* The opposite guess leads to a contradiction
                 * so the previous found solution is the only one */
          lineGuess.copy(_grid);
        } else if (nLineGuess.isSolved || nLineSolver.hasMultipleSolutions) {
          /* The opposite guess also led to a solution
                 * so there are multiple solutions */
          _multipleSolutions = true;
        } else {
          /* The opposite guess led to neither a solution or
                 * a contradiction, which can only happen if the subPuzzle
                 * is unsolvable for our maximum depth. We can learn nothing
                 * from this result. */
          _grid.updated = false;
        }
        return;
      }
      /* test for contradictions; if we encounter one we set the opposite line */
      else if (lineSolver.testContradictions()) {
        _grid.setHLine(i, j, Edge.NLINE);
        return;
      } else {
        Grid nLineGuess = Grid();
        _grid.copy(nLineGuess);

        /* make an NLINE guess */
        nLineGuess.setHLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, _rules, _contradictions,
            _selectedRules, _selectLength, depth, _epq);
        nLineSolver.solve();

        _ruleCounts = _ruleCounts + nLineSolver._ruleCounts;

        /* if both guesses led to multiple solutions, we know this puzzle
             * must also lead to another solution */
        if (nLineSolver.hasMultipleSolutions ||
            lineSolver.hasMultipleSolutions) {
          _multipleSolutions = true;
          return;
        }
        /* again check if solved. In this case we already know that we can't
             * get to a solution or contradiction with the opposite guess, so
             * we know we can't conclude whether this is the single solution */
        else if (nLineGuess.isSolved) {
          lineSolver = Solver.oldEpq(lineGuess, _rules, _contradictions,
              _selectedRules, _selectLength, max_depth, _epq);
          lineSolver.solve();

          _ruleCounts = _ruleCounts + lineSolver._ruleCounts;
          if (lineSolver.testContradictions()) {
            /* The opposite guess leads to a contradiction
                     * so the previous found solution is the only one */
            nLineGuess.copy(_grid);
          } else if (lineGuess.isSolved || lineSolver.hasMultipleSolutions) {
            /* The opposite guess also led to a solution
                     * so there are multiple solutions */
            _multipleSolutions = true;
          } else {
            /* The opposite guess led to neither a solution or
                     * a contradiction, which can only happen if the subPuzzle
                     * is unsolvable for our maximum depth. We can learn nothing
                     * from this result. */
            _grid.updated = false;
          }
          return;
        }
        /* again check for contradictions */
        else if (nLineSolver.testContradictions()) {
          _grid.setHLine(i, j, Edge.LINE);
          return;
        } else {
          _grid.updated = false;

          /* check for things that happen when we make both
                 * guesses; if we find any, we know they must happen */
          _intersectGrids(lineGuess, nLineGuess);

          if (_grid.updated) {
            return;
          }
        }
      }
    }
  }

/* Vertical guess at the given location to the given depth */
  void _makeVLineGuess(int i, int j, int depth) {
    assert(0 <= i && i < _grid.height && 0 <= j && j < _grid.width + 1);
    assert(depth >= 0);

    if (_grid.getVLine(i, j) == Edge.EMPTY) {
      /* there is only one case where the grid
         * will not be updated, which is handled
         * at the end of this iteration. */
      _grid.updated = true;

      Grid lineGuess = Grid();
      _grid.copy(lineGuess);

      /* make a LINE guess */
      lineGuess.setVLine(i, j, Edge.LINE);
      Solver lineSolver = Solver.oldEpq(lineGuess, _rules, _contradictions,
          _selectedRules, _selectLength, depth, _epq);
      lineSolver.solve();

      _ruleCounts = _ruleCounts + lineSolver._ruleCounts;

      /* If this guess happens to solve the puzzle we need to make sure that
         * the opposite guess leads to a contradiction, otherwise we know that
         * there might be multiple solutions */
      if (lineGuess.isSolved) {
        Grid nLineGuess = Grid();
        _grid.copy(nLineGuess);
        nLineGuess.setVLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, _rules, _contradictions,
            _selectedRules, _selectLength, max_depth, _epq);
        nLineSolver.solve();

        _ruleCounts = _ruleCounts + nLineSolver._ruleCounts;
        if (nLineSolver.testContradictions()) {
          /* The opposite guess leads to a contradiction
                 * so the previous found solution is the only one */
          lineGuess.copy(_grid);
        } else if (nLineGuess.isSolved || nLineSolver.hasMultipleSolutions) {
          /* The opposite guess also led to a solution
                 * so there are multiple solutions */
          _multipleSolutions = true;
        } else {
          /* The opposite guess led to neither a solution or
                 * a contradiction, which can only happen if the subPuzzle
                 * is unsolvable for our maximum depth. We can learn nothing
                 * from this result. */
          _grid.updated = false;
        }
        return;
      }
      /* test for contradictions; if we encounter one we set the opposite line */
      else if (lineSolver.testContradictions()) {
        _grid.setVLine(i, j, Edge.NLINE);
        return;
      } else {
        Grid nLineGuess = Grid();
        _grid.copy(nLineGuess);

        /* make an NLINE guess */
        nLineGuess.setVLine(i, j, Edge.NLINE);
        Solver nLineSolver = Solver.oldEpq(nLineGuess, _rules, _contradictions,
            _selectedRules, _selectLength, depth, _epq);
        nLineSolver.solve();

        _ruleCounts = _ruleCounts + nLineSolver._ruleCounts;

        /* if both guesses led to multiple solutions, we know this puzzle
             * must also lead to another solution */
        if (nLineSolver.hasMultipleSolutions ||
            lineSolver.hasMultipleSolutions) {
          _multipleSolutions = true;
          return;
        }
        /* again check if solved. In this case we already know that we can't
             * get to a solution or contradiction with the opposite guess, so
             * we know we can't conclude whether this is the single solution */
        else if (nLineGuess.isSolved) {
          lineSolver = Solver.oldEpq(lineGuess, _rules, _contradictions,
              _selectedRules, _selectLength, max_depth, _epq);
          lineSolver.solve();

          _ruleCounts = _ruleCounts + lineSolver._ruleCounts;
          if (lineSolver.testContradictions()) {
            /* The opposite guess leads to a contradiction
                     * so the previous found solution is the only one */
            nLineGuess.copy(_grid);
          } else if (lineGuess.isSolved || lineSolver.hasMultipleSolutions) {
            /* The opposite guess also led to a solution
                     * so there are multiple solutions */
            _multipleSolutions = true;
          } else {
            /* The opposite guess led to neither a solution or
                     * a contradiction, which can only happen if the subPuzzle
                     * is unsolvable for our maximum depth. We can learn nothing
                     * from this result. */
            _grid.updated = false;
          }
          return;
        }
        /* again check for contradictions */
        else if (nLineSolver.testContradictions()) {
          _grid.setVLine(i, j, Edge.LINE);
          return;
        } else {
          _grid.updated = false;

          /* check for things that happen when we make both
                 * guesses; if we find any, we know they must happen */
          _intersectGrids(lineGuess, nLineGuess);

          if (_grid.updated) {
            return;
          }
        }
      }
    }
  }

/* Checks for the intersection between lineGuess and nLineGuess grids
 * and applies any intersection to the canonical grid. */
  void _intersectGrids(Grid lineGuess, Grid nLineGuess) {
    assert(lineGuess.height == nLineGuess.height &&
        lineGuess.width == nLineGuess.width);

    for (int i = 0; i < _grid.height + 1; i++) {
      for (int j = 0; j < _grid.width; j++) {
        if (lineGuess.getHLine(i, j) == nLineGuess.getHLine(i, j) &&
            lineGuess.getHLine(i, j) != _grid.getHLine(i, j)) {
          _grid.setHLine(i, j, lineGuess.getHLine(i, j));
          _grid.updated = true;
        }
      }
    }

    for (int i = 0; i < _grid.height; i++) {
      for (int j = 0; j < _grid.width + 1; j++) {
        if (lineGuess.getVLine(i, j) == nLineGuess.getVLine(i, j) &&
            lineGuess.getVLine(i, j) != _grid.getVLine(i, j)) {
          _grid.setVLine(i, j, lineGuess.getVLine(i, j));
          _grid.updated = true;
        }
      }
    }
  }

/* Runs a loop checking each rule in each orientation in each valid
 * position on the grid, checking if the rule applies, and, if so,
 * applying it, and continue updating them until there are no longer
 * any changes being made. */
  void _applyRules(List<int> selectedRules) {
    while (_grid.updated) {
      _grid.updated = false;
      for (int i = 0; i < _grid.height; i++) {
        for (int j = 0; j < _grid.width; j++) {
          if (_grid.getUpdateMatrix(i, j)) {
            for (int x = 0; x < _selectLength; x++) {
              for (Orientation orient in Orientation.values) {
                if (_ruleApplies(i, j, _rules[selectedRules[x]], orient)) {
                  _applyRule(i, j, _rules[selectedRules[x]], orient);
                }
              }
            }
          }
          _grid.setUpdateMatrix(i, j, false);
        }
      }
    }
  }

/* Applies a rule in a given orientation to a given region of the
 * grid, overwriting all old values with any applicable values from
 * the after_ lattice for that rule. */
  void _applyRule(int i, int j, Rule rule, Orientation orient) {
    int m = rule.height;
    int n = rule.width;

    List<EdgePosition> hLineDiff = rule.hLineDiff;
    for (int k = 0; k < hLineDiff.length; k++) {
      EdgePosition pattern = hLineDiff[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (_grid.getHLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            _grid.valid =
                _grid.setHLine(adjusted.i + i, adjusted.j + j, pattern.edge);
            _grid.updated = true;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (_grid.getVLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            _grid.valid =
                _grid.setVLine(adjusted.i + i, adjusted.j + j, pattern.edge);
            _grid.updated = true;
          }
          break;
      }
    }

    List<EdgePosition> vLineDiff = rule.vLineDiff;
    for (int k = 0; k < vLineDiff.length; k++) {
      EdgePosition pattern = vLineDiff[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (_grid.getVLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            _grid.valid =
                _grid.setVLine(adjusted.i + i, adjusted.j + j, pattern.edge);
            _grid.updated = true;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (_grid.getHLine(adjusted.i + i, adjusted.j + j) == Edge.EMPTY) {
            _grid.valid =
                _grid.setHLine(adjusted.i + i, adjusted.j + j, pattern.edge);
            _grid.updated = true;
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
    int m = rule.height;
    int n = rule.width;
    if (i > _grid.height - rule.getNumberHeight(orient) ||
        j > _grid.width - rule.getNumberWidth(orient)) {
      return false;
    }

    List<NumberPosition> numberPattern = rule.numberPattern;
    for (int k = 0; k < numberPattern.length; k++) {
      NumberPosition pattern = numberPattern[k];
      Coordinates adjusted =
          rotateNumber(pattern.coords.i, pattern.coords.j, m, n, orient);

      if (pattern.num != _grid.getNumber(adjusted.i + i, adjusted.j + j)) {
        return false;
      }
    }

    List<EdgePosition> hLinePattern = rule.hLinePattern;
    for (int k = 0; k < hLinePattern.length; k++) {
      EdgePosition pattern = hLinePattern[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != _grid.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != _grid.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    List<EdgePosition> vLinePattern = rule.vLinePattern;
    for (int k = 0; k < vLinePattern.length; k++) {
      EdgePosition pattern = vLinePattern[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != _grid.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != _grid.getHLine(adjusted.i + i, adjusted.j + j)) {
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
    int m = contradiction.height;
    int n = contradiction.width;

    if (i > _grid.height - contradiction.getNumberHeight(orient) ||
        j > _grid.width - contradiction.getNumberWidth(orient)) {
      return false;
    }

    List<NumberPosition> numberPattern = contradiction.numberPattern;
    for (int k = 0; k < numberPattern.length; k++) {
      NumberPosition pattern = numberPattern[k];
      Coordinates adjusted =
          rotateNumber(pattern.coords.i, pattern.coords.j, m, n, orient);

      if (pattern.num != _grid.getNumber(adjusted.i + i, adjusted.j + j)) {
        return false;
      }
    }

    List<EdgePosition> hLinePattern = contradiction.hLinePattern;
    for (int k = 0; k < hLinePattern.length; k++) {
      EdgePosition pattern = hLinePattern[k];
      Coordinates adjusted =
          rotateHLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != _grid.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != _grid.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    List<EdgePosition> vLinePattern = contradiction.vLinePattern;
    for (int k = 0; k < vLinePattern.length; k++) {
      EdgePosition pattern = vLinePattern[k];
      Coordinates adjusted =
          rotateVLine(pattern.coords.i, pattern.coords.j, m, n, orient);

      switch (orient) {
        case Orientation.UPFLIP:
        case Orientation.UP:
        case Orientation.DOWNFLIP:
        case Orientation.DOWN:
          if (pattern.edge != _grid.getVLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
        case Orientation.LEFTFLIP:
        case Orientation.LEFT:
        case Orientation.RIGHTFLIP:
        case Orientation.RIGHT:
          if (pattern.edge != _grid.getHLine(adjusted.i + i, adjusted.j + j)) {
            return false;
          }
          break;
      }
    }

    return true;
  }
}
