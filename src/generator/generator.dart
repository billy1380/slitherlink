import 'dart:math';

import '../shared/constants.dart';
import '../shared/enums.dart';
import '../shared/export.dart';
import '../shared/grid.dart';
import '../shared/import.dart';
import '../shared/structs.dart';
import '../solver/contradiction.dart';
import '../solver/contradictions.dart';
import '../solver/rule.dart';
import '../solver/rules.dart';
import '../solver/solver.dart';
import 'loop_gen.dart';

class Generator {
  int m_;
  int n_;

  late int guessDepth_;
  late double factor_;
  late int numberCount_;
  late int smallestCount_;

  int buffer_;
  late int bufferReachCount_;
  late int zeroCount_;
  late int oneCount_;
  late int twoCount_;
  late int threeCount_;
  late List<int> selectedRules_;
  late int numberOfRules_;
  Grid grid_ = Grid();
  Grid smallestCountGrid_ = Grid();

  List<Coordinates> eligibleCoordinates_ = [];
  List<Coordinates> ineligibleCoordinates_ = [];

  late List<Rule> rules_;
  late List<Contradiction> contradictions_;
  late List<List<bool>> canEliminate_;
  late List<List<Number>> oldNumbers_;

  late Random r;

/* Generator constructor */
  Generator(this.m_, this.n_, Difficulty difficulty)
      : numberCount_ = m_ * n_,
        buffer_ = 0 {
    r = Random();

    _setDifficulty(difficulty);
    _createPuzzle();
    _displayFinalPuzzle();
  }

/* Sets the difficulty of the puzzle by imposing limitiations on the solver's capabilities */
  void _setDifficulty(Difficulty difficulty) {
    _setRules(difficulty);
    if (difficulty == Difficulty.EASY) {
      factor_ = .52;
      guessDepth_ = 1;
    } else if (difficulty == Difficulty.HARD) {
      factor_ = .42;
      guessDepth_ = 1;
    }
  }

/* Sets which rules the solver can apply */
  void _setRules(Difficulty difficulty) {
    if (difficulty == Difficulty.EASY) {
      numberOfRules_ = easy_rules.length;
      selectedRules_ = List.generate(numberOfRules_, (i) => easy_rules[i]);
    } else {
      numberOfRules_ = hard_rules.length;
      selectedRules_ = List.generate(numberOfRules_, (i) => hard_rules[i]);
    }
  }

/* Creates the puzzle by importing a puzzle,
 * creating a loop, and removing numbers */
  void _createPuzzle() {
    smallestCount_ = numberCount_;
    bufferReachCount_ = 0;
    Import importer = Import.empty(grid_, m_, n_);
    LoopGen loopgen = LoopGen(m_, n_, grid_);

    _initArrays();
    _setCounts();
    grid_.copy(smallestCountGrid_);
    _reduceNumbers();
  }

/* Prints the puzzle in its final state, both solved and unsolved */
  void _displayFinalPuzzle() {
    _checkIfSolved();
    _displayPuzzle();

    grid_.resetGrid();
    _displayPuzzle();
  }

/* Displays the puzzle, the total count of numbers, and a count of each type */
  void _displayPuzzle() {
    Export exporter = Export(grid_);
    exporter.go();
  }

/* Sets the counts of each number to the amount
 * contained before removal of numbers */
  void _setCounts() {
    zeroCount_ = 0;
    oneCount_ = 0;
    twoCount_ = 0;
    threeCount_ = 0;
    for (int i = 1; i <= m_; i++) {
      for (int j = 1; j <= n_; j++) {
        Number oldNum = grid_.getNumber(i, j);
        _plusCounts(oldNum);
      }
    }
  }

/* Adds to a number's count */
  void _plusCounts(Number num) {
    if (num == Number.ZERO) {
      zeroCount_++;
    } else if (num == Number.ONE) {
      oneCount_++;
    } else if (num == Number.TWO) {
      twoCount_++;
    } else if (num == Number.THREE) {
      threeCount_++;
    }
  }

/* Subtracts from a number's count */
  void _minusCounts(Number num) {
    if (num == Number.ZERO) {
      zeroCount_--;
    } else if (num == Number.ONE) {
      oneCount_--;
    } else if (num == Number.TWO) {
      twoCount_--;
    } else if (num == Number.THREE) {
      threeCount_--;
    }
  }

/* allocate memory for creating loop */
  void _initArrays() {
    canEliminate_ = List.generate(m_, (i) => List.filled(n_, true));
    oldNumbers_ = List.generate(
        m_, (i) => List.generate(n_, (j) => grid_.getNumber(i + 1, j + 1)));
  }

/* Reduces numbers from the puzzle until a satisfactory number has been reached */
  void _reduceNumbers() {
    // Remove numbers until this count has been reached
    while (numberCount_ > ((m_ * n_) * factor_ + 3)) {
      /* Reset the smallest count and buffer incase the required amount
        of numbers cannot be removed. */
      if (smallestCount_ > numberCount_) {
        smallestCount_ = numberCount_;
        grid_.clearAndCopy(smallestCountGrid_);
        buffer_ = (numberCount_ + (m_ * n_)) ~/ 2 - 2;
      }

      if (numberCount_ == buffer_) {
        bufferReachCount_++;
      }

      /* If the count has past the buffer three times,
         * return the grid with the smallest count of
         * of numbers that is currently known. */
      if (bufferReachCount_ == 3) {
        smallestCountGrid_.clearAndCopy(grid_);
        break;
      }

      _findNumberToRemove();
      eligibleCoordinates_.clear();

      grid_.resetGrid();
    }
  }

/* Finds a number to remove from the grid while keeping exactly one solution */
  void _findNumberToRemove() {
    _fillEligibleVector();
    bool coordsFound = false;

    while (eligibleCoordinates_.isNotEmpty && !coordsFound) {
      int random = r.nextInt(eligibleCoordinates_.length);
      Coordinates attempt = eligibleCoordinates_[random];
      eligibleCoordinates_.removeAt(random);

      // Checks if the number in question is needed to retain a balance
      if (_isBalanced(attempt.i, attempt.j)) {
        _removeNumber(attempt.i, attempt.j);

        // If unsolvable, bring number back and look for another
        if (!_checkIfSolved()) {
          _setOldNumber(attempt.i, attempt.j);
          _markNecessary(attempt.i, attempt.j);
        } else {
          ineligibleCoordinates_.add(attempt);
          coordsFound = true;
          numberCount_--;
          _minusCounts(oldNumbers_[attempt.i - 1][attempt.j - 1]);
        }
      }
    }

    // If no more candidates, bring back the previously removed number
    if (!coordsFound && numberCount_ < m_ * n_) {
      _getNecessaryCoordinate();
      numberCount_++;
    }
  }

/* Determines if the puzzle contains a proper ratio of Number types */
  bool _isBalanced(int i, int j) {
    double moa = 1.1;
    Number num = grid_.getNumber(i, j);
    if (num == Number.THREE) {
      return (threeCount_ * 2 * moa >= 3 * oneCount_ &&
          threeCount_ * 5 * moa >= 3 * twoCount_);
    } else if (num == Number.TWO) {
      return (twoCount_ * 2.1 + 1 >= 5 * oneCount_ &&
          twoCount_ * 3 * moa >= 5 * threeCount_);
    } else if (num == Number.ONE) {
      return (oneCount_ * 3 * moa >= 2 * threeCount_ &&
          oneCount_ * 5 * moa >= 2 * twoCount_);
    } else {
      return false;
    }
  }

/* Adds Coordinates of Numbers that are eligible for elimination to a vector */
  void _fillEligibleVector() {
    for (int i = 1; i < m_ + 1; i++) {
      for (int j = 1; j < n_ + 1; j++) {
        if (_eligible(i, j)) {
          Coordinates coords = Coordinates(i, j);
          eligibleCoordinates_.add(coords);
        }
      }
    }
  }

  bool _checkIfSolved() {
    List<Rule> rules_ = List.generate(num_rules, initRules);

    List<Contradiction> contradictions_ =
        List.generate(num_contradictions, initContradictions);
    grid_.resetGrid();

    Solver solver = Solver(grid_, rules_, contradictions_, selectedRules_,
        numberOfRules_, guessDepth_);
    return grid_.isSolved;
  }

/* Pops Coordinates out of ineligible vector, marking
 * each as eligible until one is found that has been removed.
 * This one is then marked as necessary */
  void _getNecessaryCoordinate() {
    bool found = false;

    while (!found) {
      Coordinates popped = ineligibleCoordinates_.last;
      if (grid_.getNumber(popped.i, popped.j) == Number.NONE) {
        _markNecessary(popped.i, popped.j);
        _setOldNumber(popped.i, popped.j);
        ineligibleCoordinates_.add(popped);
        _plusCounts(grid_.getNumber(popped.i, popped.j));
        found = true;
      } else {
        ineligibleCoordinates_.removeLast();
        _markEligible(popped.i, popped.j);
      }
    }
  }

/* Sets a space in the grid back to its original number */
  void _setOldNumber(int i, int j) {
    grid_.setNumber(i, j, oldNumbers_[i - 1][j - 1]);
  }

/* Elimates a number at a set of coordinates */
  void _removeNumber(int i, int j) {
    grid_.setNumber(i, j, Number.NONE);
    grid_.resetGrid();
    Coordinates removed = Coordinates(i, j);
    ineligibleCoordinates_.add(removed);
  }

/* Elimates a number at a set of coordinates */
  void _eliminateNumber(int i, int j) {
    grid_.setNumber(i, j, Number.NONE);
    grid_.resetGrid();
    canEliminate_[i - 1][j - 1] = false;
  }

/* Determines if a Number at Coordinates is eligible for elimination */
  bool _eligible(int i, int j) {
    if (canEliminate_[i - 1][j - 1] && (grid_.getNumber(i, j) != Number.NONE)) {
      return true;
    } else {
      return false;
    }
  }

/* Marks a Number at specific Coordinates as eligible for elimination */
  void _markEligible(int i, int j) {
    canEliminate_[i - 1][j - 1] = true;
  }

/* Marks a Number at specific Coordinates as ineligible for elimination
 * due to its necessity to complete the puzzle at this configuration */
  void _markNecessary(int i, int j) {
    canEliminate_[i - 1][j - 1] = false;
  }

/* Another method for removing numbers */
  void _deleteNumbers() {
    _setCounts();
    int count = 0;
    int i = r.nextInt(m_) + 1;
    int j = r.nextInt(n_) + 1;
    Number oldNum = grid_.getNumber(i, j);
    while (count < ((m_) * (n_) * 2 / 3 + 10)) {
      count++;
      int count2 = 0;
      while (true) {
        i = r.nextInt(m_) + 1;
        j = r.nextInt(n_) + 1;
        oldNum = grid_.getNumber(i, j);
        if (_isBalancedNum(i, j, oldNum)) {
          break;
        }
        count2++;
        if (count2 > n_ + m_) {
          if (_eligible(i, j) || oldNum == Number.NONE) {
            count += (m_ + n_) ~/ 2;
            break;
          }
        }
      }
      _eliminateNumber(i, j);
      //exporter.print();

      // TODO: maybe modify selected rules

      Solver solver = Solver(grid_, rules_, contradictions_, selectedRules_,
          num_rules - num_const_rules, 1);
      if (!grid_.isSolved) {
        grid_.setNumber(i, j, oldNum);
      } else {
        _minusCounts(oldNum);
      }
      grid_.resetGrid();
    }
  }

  bool _isBalancedNum(int i, int j, Number num) {
    if (_eligible(i, j)) {
      if (num == Number.ZERO) {
        return true;
      }
      if (num == Number.THREE) {
        return (threeCount_ * 2.1 + 1 > 3 * oneCount_ &&
            threeCount_ * 5.2 + 1 > 3 * twoCount_);
      }
      if (num == Number.ONE) {
        return (oneCount_ * 3.2 + 1 > 2 * threeCount_ &&
            oneCount_ * 5.2 + 1 > 2 * twoCount_);
      }
      if (num == Number.TWO) {
        return (twoCount_ * 2.1 + 1 > 5 * oneCount_ &&
            twoCount_ * 3.1 + 1 > 5 * threeCount_);
      }
    }
    return false;
  }
}
