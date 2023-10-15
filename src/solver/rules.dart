/* Initializes the rules array with each deterministic rule
 * used by the Solver to complete the grid. By convention the
 * rules will be represented with width <= height, although
 * each rule will be applied in each possible orientation. */
import '../shared/enums.dart';
import 'rule.dart';

final Rule emptyRule = Rule(-1, -1);

Rule initRules(int i) {
  // Lattice * before;
  // Lattice * after;

  Rule r;

  if (i == 0) {
    /**
     * Rule #1
     * Before       After
     * .   .   .    .   .   .
     *     x
     * . x . x .    .   .   .
     *                  x
     * .   .   .    .   .   .
     */

    r = Rule(2, 2);

    r.addHLinePattern(1, 0, Edge.nLine);
    r.addHLinePattern(1, 1, Edge.nLine);
    r.addVLinePattern(0, 1, Edge.nLine);

    r.addVLineDiff(1, 1, Edge.nLine);
  } else if (i == 1) {
    /**
     * Rule #2
     * Before       After
     * .   .   .    .   .   .
     *     |
     * . - .   .    .   . x .
     *                  x
     * .   .   .    .   .   .
     */

    r = Rule(2, 2);

    r.addHLinePattern(1, 0, Edge.line);
    r.addVLinePattern(0, 1, Edge.line);

    r.addVLineDiff(1, 1, Edge.nLine);
    r.addHLineDiff(1, 1, Edge.nLine);
  } else if (i == 2) {
    /**
     * Rule #3
     * Before       After
     * .   .   .    .   .   .
     *                  x
     * . - . - .    .   .   .
     *                  x
     * .   .   .    .   .   .
     */

    r = Rule(2, 2);

    r.addHLinePattern(1, 0, Edge.line);
    r.addHLinePattern(1, 1, Edge.line);

    r.addVLineDiff(0, 1, Edge.nLine);
    r.addVLineDiff(1, 1, Edge.nLine);
  } else if (i == 3) {
    /**
     * Rule #4
     * Before       After
     * .   .   .    .   .   .
     *     x
     * . - .   .    .   . - .
     *     x
     * .   .   .    .   .   .
     */

    r = Rule(2, 2);

    r.addHLinePattern(1, 0, Edge.line);
    r.addVLinePattern(0, 1, Edge.nLine);
    r.addVLinePattern(1, 1, Edge.nLine);

    r.addHLineDiff(1, 1, Edge.line);
  } else if (i == 4) {
    /**
     * Rule #5
     * Before       After
     * .   .   .    .   .   .
     *     x
     * . - . x .    .   .   .
     *                  |
     * .   .   .    .   .   .
     */

    r = Rule(2, 2);

    r.addHLinePattern(1, 0, Edge.line);
    r.addHLinePattern(1, 1, Edge.nLine);
    r.addVLinePattern(0, 1, Edge.nLine);

    r.addVLineDiff(1, 1, Edge.line);
  } else if (i == 5) {
    /**
     * Rule #6
     * Before   After
     * . - .    .   .
     *   1      x   x
     * .   .    . x .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.one);
    r.addHLinePattern(0, 0, Edge.line);

    r.addHLineDiff(1, 0, Edge.nLine);
    r.addVLineDiff(0, 0, Edge.nLine);
    r.addVLineDiff(0, 1, Edge.nLine);
  } else if (i == 6) {
    /**
     * Rule #7
     * Before   After
     * .   .    . - .
     * x 1 x
     * . x .    .   .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.one);
    r.addHLinePattern(1, 0, Edge.nLine);
    r.addVLinePattern(0, 0, Edge.nLine);
    r.addVLinePattern(0, 1, Edge.nLine);

    r.addHLineDiff(0, 0, Edge.line);
  } else if (i == 7) {
    /**
     * Rule #8
     * Before   After
     * . - .    .   .
     * | 2          x
     * .   .    . x .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.two);
    r.addHLinePattern(0, 0, Edge.line);
    r.addVLinePattern(0, 0, Edge.line);

    r.addHLineDiff(1, 0, Edge.nLine);
    r.addVLineDiff(0, 1, Edge.nLine);
  } else if (i == 8) {
    /**
     * Rule #9
     * Before   After
     * .   .    . - .
     *   2 x    |
     * . x .    .   .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.two);
    r.addHLinePattern(1, 0, Edge.nLine);
    r.addVLinePattern(0, 1, Edge.nLine);

    r.addHLineDiff(0, 0, Edge.line);
    r.addVLineDiff(0, 0, Edge.line);
  } else if (i == 9) {
    /**
     * Rule #10
     * Before   After
     * . - .    .   .
     *   2      x   x
     * . - .    .   .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.two);
    r.addHLinePattern(0, 0, Edge.line);
    r.addHLinePattern(1, 0, Edge.line);

    r.addVLineDiff(0, 0, Edge.nLine);
    r.addVLineDiff(0, 1, Edge.nLine);
  } else if (i == 10) {
    /**
     * Rule #11
     * Before   After
     * .   .    . - .
     * x 2 x
     * .   .    . - .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.two);
    r.addVLinePattern(0, 0, Edge.nLine);
    r.addVLinePattern(0, 1, Edge.nLine);

    r.addHLineDiff(0, 0, Edge.line);
    r.addHLineDiff(1, 0, Edge.line);
  } else if (i == 11) {
    /**
     * Rule #12
     * Before   After
     * . x .    .   .
     *   3      |   |
     * .   .    . - .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.three);
    r.addHLinePattern(0, 0, Edge.nLine);

    r.addVLineDiff(0, 0, Edge.line);
    r.addVLineDiff(0, 1, Edge.line);
    r.addHLineDiff(1, 0, Edge.line);
  } else if (i == 12) {
    /** Rule 13
     * Before         After
     * .   .   .   .      .   .   .   .
     *         |
     * .   .   . x .      .   .   .   .
     *       1                x
     * .   .   .   .      .   . x .   .
     *
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(0, 2, Edge.line);
    r.addHLinePattern(1, 2, Edge.nLine);

    r.addVLineDiff(1, 1, Edge.nLine);
    r.addHLineDiff(2, 1, Edge.nLine);
  } else if (i == 13) {
    /** Rule 14
     * Before         After
     * .   .   .   .      .   .   .   .
     *         |
     * .   .   .   .      .   .   . x .
     *     x 1
     * .   . x .   .      .   .   .   .
     *
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(0, 2, Edge.line);
    r.addVLinePattern(1, 1, Edge.nLine);
    r.addHLinePattern(2, 1, Edge.nLine);

    r.addHLineDiff(1, 2, Edge.nLine);
  } else if (i == 14) {
    /** Rule 15
     * Before         After
     * .   .   .   .      .   .   .   .
     *
     * .   .   .   .      .   .   .   .
     *       1                x
     * . x .   .   .      .   . x .   .
     *     x
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(2, 1, Edge.nLine);
    r.addHLinePattern(2, 0, Edge.nLine);

    r.addVLineDiff(1, 1, Edge.nLine);
    r.addHLineDiff(2, 1, Edge.nLine);
  } else if (i == 15) {
    /** Rule 16
     * Before         After
     * .   .   .   .      .   .   .   .
     *     |   |
     * . x .   . x .      .   . _ .   .
     *       1
     * .   .   .   .      .   .   .   .
     *
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(0, 1, Edge.line);
    r.addVLinePattern(0, 2, Edge.line);
    r.addHLinePattern(1, 2, Edge.nLine);
    r.addHLinePattern(1, 0, Edge.nLine);

    r.addHLineDiff(1, 1, Edge.line);
  } else if (i == 16) {
    /** Rule 17
     * Before         After
     * .   .   .   .      .   .   .   .
     *
     * .   . x .   .      .   .   .   .
     *       2                |
     * . x .   .   .      .   . _ .   .
     *     x
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.two);
    r.addVLinePattern(2, 1, Edge.nLine);
    r.addHLinePattern(2, 0, Edge.nLine);
    r.addHLinePattern(1, 1, Edge.nLine);

    r.addHLineDiff(2, 1, Edge.line);
    r.addVLineDiff(1, 1, Edge.line);
  } else if (i == 17) {
    /** Rule 18
     * Before         After
     * .   .   .   .      .   .   .   .
     *     x   x
     * .   .   . x .      . _ .   .   .
     *       2
     * .   .   . x .      .   .   .   .
     *                            |
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.two);
    r.addVLinePattern(0, 1, Edge.nLine);
    r.addVLinePattern(0, 2, Edge.nLine);
    r.addHLinePattern(1, 2, Edge.nLine);
    r.addHLinePattern(2, 2, Edge.nLine);

    r.addHLineDiff(1, 0, Edge.line);
    r.addVLineDiff(2, 2, Edge.line);
  } else if (i == 18) {
    /** Rule 19
     * Before         After
     * .   .   .   .      .   .   .   .
     *     x   x
     * .   .   . x .      . _ .   .   .
     *       2
     * .   .   .   .      .   .   .   .
     *
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.two);
    r.addVLinePattern(0, 1, Edge.nLine);
    r.addVLinePattern(0, 2, Edge.nLine);
    r.addHLinePattern(1, 2, Edge.nLine);

    r.addHLineDiff(1, 0, Edge.line);
  } else if (i == 19) {
    /** Rule 20
     * Before         After
     * .   .   .   .      .   .   .   .
     *         |
     * .   .   .   .      .   .   . x .
     *       3                |
     * .   .   .   .      .   . _ .   .
     *
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.three);
    r.addVLinePattern(0, 2, Edge.line);

    r.addHLineDiff(2, 1, Edge.line);
    r.addHLineDiff(1, 2, Edge.nLine);
    r.addVLineDiff(1, 1, Edge.line);
  } else if (i == 20) {
    /** Rule 21
     * Before         After
     * .   .   .   .      .   .   .   .
     *
     * .   .   .   .      .   .   .   .
     *       3                |
     * . x .   .   .      .   . _ .   .
     *     x
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addNumberPattern(1, 1, Number.three);
    r.addVLinePattern(2, 1, Edge.nLine);
    r.addHLinePattern(2, 0, Edge.nLine);

    r.addHLineDiff(2, 1, Edge.line);
    r.addVLineDiff(1, 1, Edge.line);
  } else if (i == 21) {
    /** Rule 22
     * Before         After
     * .   .   .      .   .   .
     *   3   1
     * .   .   .      . _ .   .
     * x   x
     * .   .   .      .   .   .
     *
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 0, Number.three);
    r.addNumberPattern(0, 1, Number.one);
    r.addVLinePattern(1, 0, Edge.nLine);
    r.addVLinePattern(1, 1, Edge.nLine);

    r.addHLineDiff(1, 0, Edge.line);
  } else if (i == 22) {
    /** Rule 23
     * Before         After
     * .   .   .   .      .   .   .   .
     *     x   x
     * . x .   . _ .      .   .   .   .
     *
     * . x .   . x .      .   .   .   .
     *         x              |
     * .   .   .   .      .   .   .   .
     *
     */

    r = Rule(3, 3);

    r.addVLinePattern(0, 1, Edge.nLine);
    r.addVLinePattern(0, 2, Edge.nLine);
    r.addVLinePattern(2, 2, Edge.nLine);
    r.addHLinePattern(1, 2, Edge.line);
    r.addHLinePattern(1, 0, Edge.nLine);
    r.addHLinePattern(2, 0, Edge.nLine);
    r.addHLinePattern(2, 2, Edge.nLine);

    r.addVLineDiff(2, 1, Edge.line);
  } else if (i == 23) {
    /** Rule 24
     * Before         After
     *
     * . _ .      .   .
     * |   |
     * .   .      . x .
     *
     */

    r = Rule(1, 1);

    r.addVLinePattern(0, 0, Edge.line);
    r.addVLinePattern(0, 1, Edge.line);
    r.addHLinePattern(0, 0, Edge.line);

    r.addHLineDiff(1, 0, Edge.nLine);
  } else if (i == 24) {
    /** Rule 25
     * Before         After
     *
     * . x .   .     .   .   .
     * x 1
     * .   .   .     .   .   .
     *       1               x
     * .   .   .     .   . x .
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 0, Number.one);
    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(0, 0, Edge.nLine);
    r.addHLinePattern(0, 0, Edge.nLine);

    r.addHLineDiff(2, 1, Edge.nLine);
    r.addVLineDiff(1, 2, Edge.nLine);
  } else if (i == 25) {
    /** Rule 26
     * Before         After
     *
     * .   .   .     .   .   .
     *     x
     * . x .   .     .   . x .
     *       1           x
     * .   .   .     .   .   .
     */

    r = Rule(2, 2);

    r.addNumberPattern(1, 1, Number.one);
    r.addVLinePattern(0, 1, Edge.nLine);
    r.addHLinePattern(1, 0, Edge.nLine);

    r.addHLineDiff(1, 1, Edge.nLine);
    r.addVLineDiff(1, 1, Edge.nLine);
  } else if (i == 26) {
    /** Rule 27
     * Before         After
     *
     * .   . x .     .   .   .
     *       2               |
     * . - .   .     .   .   .
     *                   x
     * .   .   .     .   .   .
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 1, Number.two);
    r.addHLinePattern(0, 1, Edge.nLine);
    r.addHLinePattern(1, 0, Edge.line);

    r.addVLineDiff(0, 2, Edge.line);
    r.addVLineDiff(1, 1, Edge.nLine);
  } else if (i == 27) {
    /** Rule 28
     * Before         After
     *
     * .   .   .     .   . - .
     *       2               |
     * . - .   .     .   .   .
     *     |
     * .   .   .     .   .   .
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 1, Number.two);
    r.addHLinePattern(1, 0, Edge.line);
    r.addVLinePattern(1, 1, Edge.line);

    r.addHLineDiff(0, 1, Edge.line);
    r.addVLineDiff(0, 2, Edge.line);
  } else if (i == 28) {
    /** Rule 29
     * Before         After
     *
     * . - .   .     .   .   .
     * | 3
     * .   .   .     .   .   .
     *       1               x
     * .   .   .     .   . x .
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 0, Number.three);
    r.addNumberPattern(1, 1, Number.one);
    r.addHLinePattern(0, 0, Edge.line);
    r.addVLinePattern(0, 0, Edge.line);

    r.addHLineDiff(2, 1, Edge.nLine);
    r.addVLineDiff(1, 2, Edge.nLine);
  } else if (i == 29) {
    /** Rule 30
     * Before         After
     *
     * .   .   .     . - .   .
     *   3           |
     * .   .   .     .   .   .
     *       1 x
     * .   . x .     .   .   .
     */

    r = Rule(2, 2);

    r.addNumberPattern(0, 0, Number.three);
    r.addNumberPattern(1, 1, Number.one);
    r.addHLinePattern(2, 1, Edge.nLine);
    r.addVLinePattern(1, 2, Edge.nLine);

    r.addHLineDiff(0, 0, Edge.line);
    r.addVLineDiff(0, 0, Edge.line);
  } else if (i == 30) {
    /**
     * Rule #31
     * Before   After
     * .   .    . x .
     *   0      x   x
     * .   .    . x .
     */

    r = Rule(1, 1);

    r.addNumberPattern(0, 0, Number.zero);

    r.addHLineDiff(0, 0, Edge.nLine);
    r.addHLineDiff(1, 0, Edge.nLine);
    r.addVLineDiff(0, 0, Edge.nLine);
    r.addVLineDiff(0, 1, Edge.nLine);
  } else if (i == 31) {
    /**
     * Rule 32
     * Before       After
     * .   .   .    .   . _ .
     *       3              |
     * .   .   .    .   .   .
     *   3          |
     * .   .   .    . _ .   .
     */

    r = Rule(2, 2);

    r.addNumberPattern(1, 0, Number.three);
    r.addNumberPattern(0, 1, Number.three);

    r.addHLineDiff(0, 1, Edge.line);
    r.addHLineDiff(2, 0, Edge.line);
    r.addVLineDiff(1, 0, Edge.line);
    r.addVLineDiff(0, 2, Edge.line);
  } else if (i == 32) {
    /**
     * Rule 33
     * Before       After
     * .   .   .    .   .   .
     *                  x
     * .   .   .    .   .   .
     *   3   3      |   |   |
     * .   .   .    .   .   .
     *                  x
     * .   .   .    .   .   .
     */

    r = Rule(3, 2);

    r.addNumberPattern(1, 0, Number.three);
    r.addNumberPattern(1, 1, Number.three);

    r.addVLineDiff(1, 0, Edge.line);
    r.addVLineDiff(1, 1, Edge.line);
    r.addVLineDiff(1, 2, Edge.line);
    r.addVLineDiff(0, 1, Edge.nLine);
    r.addVLineDiff(2, 1, Edge.nLine);
  } else {
    r = emptyRule;
  }

  return r;
}
