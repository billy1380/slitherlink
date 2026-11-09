import '../shared/constants.dart';
import '../shared/enums.dart';
import '../shared/grid.dart';
import '../shared/import.dart';
import '../shared/random.dart';
import '../shared/structs.dart';
import '../solver/contradiction.dart';
import '../solver/contradictions.dart';
import '../solver/rule.dart';
import '../solver/rules.dart';
import '../solver/solver.dart';
import 'loop_gen.dart';

class GeneratedPuzzle {
  final Grid puzzle;
  final Grid solution;

  const GeneratedPuzzle(this.puzzle, this.solution);
}

class Generator {
  final int _m;
  final int _n;

  late int _guessDepth;
  late double _factor;
  late int _numberCount;
  late int _smallestCount;

  int _buffer;
  late int _bufferReachCount;
  // late int _zeroCount;
  late int _oneCount;
  late int _twoCount;
  late int _threeCount;
  late List<int> _selectedRules;
  late int _numberOfRules;
  final Grid _grid = Grid();
  final Grid _smallestCountGrid = Grid();
  final Grid _loopGrid = Grid();

  final List<Coordinates> _eligibleCoordinates = <Coordinates>[];
  final List<Coordinates> _ineligibleCoordinates = <Coordinates>[];

  final List<Rule> _rules = List<Rule>.generate(numRules, initRules);
  final List<Contradiction> _contradictions =
      List<Contradiction>.generate(numContradictions, initContradictions);
  late List<List<bool>> _canEliminate;
  late List<List<Number>> _oldNumbers;

  /// Generator constructor
  Generator(this._m, this._n)
      : _numberCount = _m * _n,
        _buffer = 0;

  int _attempts = 0;
  bool _finished = false;
  bool _removing = false;
  bool _coordsFound = false;
  GeneratedPuzzle? _result;

  GeneratedPuzzle generate(Difficulty difficulty) {
    begin(difficulty);
    while (!step()) {}
    return result;
  }

  /// Starts a puzzle: call [step] until it returns true, then read [result]
  void begin(Difficulty difficulty) {
    _setDifficulty(difficulty);
    _createPuzzle();
    _attempts = 0;
    _finished = false;
    _removing = false;
    _result = null;
  }

  /// The finished puzzle, only valid once [step] has returned true
  GeneratedPuzzle get result => _result ??= _finalPuzzle();

  /// Sets the difficulty of the puzzle by imposing limitiations on the solver's capabilities
  void _setDifficulty(Difficulty difficulty) {
    _setRules(difficulty);
    if (difficulty == Difficulty.easy) {
      _factor = .52;
      _guessDepth = 1;
    } else if (difficulty == Difficulty.hard) {
      _factor = .42;
      _guessDepth = 1;
    }
  }

  /// Sets which rules the solver can apply
  void _setRules(Difficulty difficulty) {
    if (difficulty == Difficulty.easy) {
      _numberOfRules = easyRules.length;
      _selectedRules =
          List<int>.generate(_numberOfRules, (int i) => easyRules[i]);
    } else {
      _numberOfRules = hardRules.length;
      _selectedRules =
          List<int>.generate(_numberOfRules, (int i) => hardRules[i]);
    }
  }

  /// Creates the puzzle by importing a puzzle,
  /// creating a loop, and removing numbers
  void _createPuzzle() {
    _smallestCount = _numberCount;
    _bufferReachCount = 0;

    Import importer = Import(_grid);
    importer.buildEmptyLattice(_m, _n);

    LoopGen loopgen = LoopGen(_m, _n, _grid);
    loopgen.generate();
    _grid.copy(_loopGrid);
    loopgen.fillLines(_loopGrid);

    _initArrays();
    _setCounts();
    _grid.copy(_smallestCountGrid);
  }

  /// The puzzle in its final state, both solved and unsolved
  GeneratedPuzzle _finalPuzzle() {
    _grid.resetGrid();
    Grid unsolved = Grid();
    _grid.copy(unsolved);

    return GeneratedPuzzle(unsolved, _loopGrid);
  }

  /// Sets the counts of each number to the amount
  /// contained before removal of numbers
  void _setCounts() {
    // _zeroCount = 0;
    _oneCount = 0;
    _twoCount = 0;
    _threeCount = 0;
    for (int i = 1; i <= _m; i++) {
      for (int j = 1; j <= _n; j++) {
        Number oldNum = _grid.getNumber(i, j);
        _plusCounts(oldNum);
      }
    }
  }

  /// Adds to a number's count
  void _plusCounts(Number num) {
    if (num == Number.zero) {
      // _zeroCount++;
    } else if (num == Number.one) {
      _oneCount++;
    } else if (num == Number.two) {
      _twoCount++;
    } else if (num == Number.three) {
      _threeCount++;
    }
  }

  /// Subtracts from a number's count
  void _minusCounts(Number num) {
    if (num == Number.zero) {
      // _zeroCount--;
    } else if (num == Number.one) {
      _oneCount--;
    } else if (num == Number.two) {
      _twoCount--;
    } else if (num == Number.three) {
      _threeCount--;
    }
  }

  /// allocate memory for creating loop
  void _initArrays() {
    _canEliminate =
        List<List<bool>>.generate(_m, (int i) => List<bool>.filled(_n, true));
    _oldNumbers = List<List<Number>>.generate(
        _m,
        (int i) => List<Number>.generate(
            _n, (int j) => _grid.getNumber(i + 1, j + 1)));
  }

  /// Does one small piece of work, at most one solve, to reduce the numbers.
  /// Returns true once the puzzle is finished.
  bool step() {
    if (_finished) return true;

    if (!_removing) {
      // Remove numbers until this count has been reached
      if (_numberCount <= ((_m * _n * _factor) + 3)) return _finish();

      // The loop stalls when no number can be removed, so give up and keep the smallest grid.
      if (_attempts++ > _m * _n * 50) {
        _smallestCountGrid.clearAndCopy(_grid);
        return _finish();
      }

      /* Reset the smallest count and buffer incase the required amount
        of numbers cannot be removed. */
      if (_smallestCount > _numberCount) {
        _smallestCount = _numberCount;
        _grid.clearAndCopy(_smallestCountGrid);
        _buffer = ((_numberCount + (_m * _n)) ~/ 2) - 2;
      }

      if (_numberCount == _buffer) {
        _bufferReachCount++;
      }

      /* If the count has past the buffer three times,
         * return the grid with the smallest count of
         * of numbers that is currently known. */
      if (_bufferReachCount == 3) {
        _smallestCountGrid.clearAndCopy(_grid);
        return _finish();
      }

      _fillEligibleVector();
      _coordsFound = false;
      _removing = true;
    }

    if (_eligibleCoordinates.isNotEmpty && !_coordsFound) {
      _tryRemoval();
    }

    if (_eligibleCoordinates.isEmpty || _coordsFound) {
      // If no more candidates, bring back the previously removed number
      if (!_coordsFound && _numberCount < _m * _n) {
        _getNecessaryCoordinate();
        _numberCount++;
      }

      _eligibleCoordinates.clear();
      _grid.resetGrid();
      _removing = false;
    }

    return false;
  }

  bool _finish() {
    _finished = true;
    return true;
  }

  /// Tries to remove one random eligible number while keeping exactly one solution
  void _tryRemoval() {
    int random = r.nextInt(_eligibleCoordinates.length);
    Coordinates attempt = _eligibleCoordinates.removeAt(random);

    // Checks if the number in question is needed to retain a balance
    if (_isBalanced(attempt.i, attempt.j)) {
      _removeNumber(attempt.i, attempt.j);

      // If unsolvable, bring number back and look for another
      if (!_checkIfSolved()) {
        _setOldNumber(attempt.i, attempt.j);
        _markNecessary(attempt.i, attempt.j);
      } else {
        _ineligibleCoordinates.add(attempt);
        _coordsFound = true;
        _numberCount--;
        _minusCounts(_oldNumbers[attempt.i - 1][attempt.j - 1]);
      }
    }
  }

  /// Determines if the puzzle contains a proper ratio of Number types
  bool _isBalanced(int i, int j) {
    double moa = 1.1;
    Number num = _grid.getNumber(i, j);
    if (num == Number.three) {
      return (_threeCount * 2 * moa >= 3 * _oneCount &&
          _threeCount * 5 * moa >= 3 * _twoCount);
    } else if (num == Number.two) {
      return (_twoCount * 2.1 + 1 >= 5 * _oneCount &&
          _twoCount * 3 * moa >= 5 * _threeCount);
    } else if (num == Number.one) {
      return (_oneCount * 3 * moa >= 2 * _threeCount &&
          _oneCount * 5 * moa >= 2 * _twoCount);
    } else {
      return false;
    }
  }

  /// Adds Coordinates of Numbers that are eligible for elimination to a vector
  void _fillEligibleVector() {
    for (int i = 1; i < _m + 1; i++) {
      for (int j = 1; j < _n + 1; j++) {
        if (_eligible(i, j)) {
          Coordinates coords = Coordinates(i, j);
          _eligibleCoordinates.add(coords);
        }
      }
    }
  }

  bool _checkIfSolved() {
    _grid.resetGrid();

    Solver solver = Solver(_grid, _rules, _contradictions, _selectedRules,
        _numberOfRules, _guessDepth);
    solver.solve();

    return _grid.isSolved;
  }

  /// Pops Coordinates out of ineligible vector, marking
  /// each as eligible until one is found that has been removed.
  /// This one is then marked as necessary
  void _getNecessaryCoordinate() {
    bool found = false;

    while (!found) {
      Coordinates popped = _ineligibleCoordinates.last;
      if (_grid.getNumber(popped.i, popped.j) == Number.none) {
        _markNecessary(popped.i, popped.j);
        _setOldNumber(popped.i, popped.j);
        _ineligibleCoordinates.add(popped);
        _plusCounts(_grid.getNumber(popped.i, popped.j));
        found = true;
      } else {
        _ineligibleCoordinates.removeLast();
        _markEligible(popped.i, popped.j);
      }
    }
  }

  /// Sets a space in the grid back to its original number
  void _setOldNumber(int i, int j) {
    _grid.setNumber(i, j, _oldNumbers[i - 1][j - 1]);
  }

  /// Elimates a number at a set of coordinates
  void _removeNumber(int i, int j) {
    _grid.setNumber(i, j, Number.none);
    _grid.resetGrid();
    Coordinates removed = Coordinates(i, j);
    _ineligibleCoordinates.add(removed);
  }

// /* Elimates a number at a set of coordinates */
//   void _eliminateNumber(int i, int j) {
//     grid_.setNumber(i, j, Number.NONE);
//     grid_.resetGrid();
//     canEliminate_[i - 1][j - 1] = false;
//   }

  /// Determines if a Number at Coordinates is eligible for elimination
  bool _eligible(int i, int j) {
    if (_canEliminate[i - 1][j - 1] && (_grid.getNumber(i, j) != Number.none)) {
      return true;
    } else {
      return false;
    }
  }

  /// Marks a Number at specific Coordinates as eligible for elimination
  void _markEligible(int i, int j) {
    _canEliminate[i - 1][j - 1] = true;
  }

  /// Marks a Number at specific Coordinates as ineligible for elimination
  /// due to its necessity to complete the puzzle at this configuration
  void _markNecessary(int i, int j) {
    _canEliminate[i - 1][j - 1] = false;
  }

// /* Another method for removing numbers */
//   void _deleteNumbers() {
//     _setCounts();
//     int count = 0;
//     int i = r.nextInt(m_) + 1;
//     int j = r.nextInt(n_) + 1;
//     Number oldNum = grid_.getNumber(i, j);
//     while (count < ((m_) * (n_) * 2 / 3 + 10)) {
//       count++;
//       int count2 = 0;
//       while (true) {
//         i = r.nextInt(m_) + 1;
//         j = r.nextInt(n_) + 1;
//         oldNum = grid_.getNumber(i, j);
//         if (_isBalancedNum(i, j, oldNum)) {
//           break;
//         }
//         count2++;
//         if (count2 > n_ + m_) {
//           if (_eligible(i, j) || oldNum == Number.NONE) {
//             count += (m_ + n_) ~/ 2;
//             break;
//           }
//         }
//       }
//       _eliminateNumber(i, j);
//       //exporter.print();

//       // TODO_: maybe modify selected rules

//       Solver solver = Solver(grid_, rules_, contradictions_, selectedRules_,
//           num_rules - num_const_rules, 1);
//       solver.solve();

//       if (!grid_.isSolved) {
//         grid_.setNumber(i, j, oldNum);
//       } else {
//         _minusCounts(oldNum);
//       }
//       grid_.resetGrid();
//     }
//   }

  // bool _isBalancedNum(int i, int j, Number num) {
  //   if (_eligible(i, j)) {
  //     if (num == Number.ZERO) {
  //       return true;
  //     }
  //     if (num == Number.THREE) {
  //       return (threeCount_ * 2.1 + 1 > 3 * oneCount_ &&
  //           threeCount_ * 5.2 + 1 > 3 * twoCount_);
  //     }
  //     if (num == Number.ONE) {
  //       return (oneCount_ * 3.2 + 1 > 2 * threeCount_ &&
  //           oneCount_ * 5.2 + 1 > 2 * twoCount_);
  //     }
  //     if (num == Number.TWO) {
  //       return (twoCount_ * 2.1 + 1 > 5 * oneCount_ &&
  //           twoCount_ * 3.1 + 1 > 5 * threeCount_);
  //     }
  //   }
  //   return false;
  // }
}
