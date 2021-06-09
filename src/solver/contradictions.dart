import '../shared/enums.dart';
import 'contradiction.dart';

final Contradiction empty_contradiction = Contradiction(-1, -1);

/* Initializes the contradictions array with each contradiction
 * used by the Solver to complete the grid. By convention the
 * contradictions will be represented with width <= height,
 * although each contradiction will be applied in each possible
 * orientation. */
Contradiction initContradictions(int i) {
  Contradiction c;

  if (i == 0) {
    /**
     * Contradiction #01
     * .   .   .
     *     x
     * . x . x .
     *     |
     * .   .   .
     */
    c = Contradiction(2, 2);

    c.addHLinePattern(1, 0, Edge.NLINE);
    c.addHLinePattern(1, 1, Edge.NLINE);
    c.addVLinePattern(0, 1, Edge.NLINE);
    c.addVLinePattern(1, 1, Edge.LINE);
  } else if (i == 1) {
    /**
     * Contradiction #02
     * .   .   .
     *     |
     * . _ . _ .
     *
     */
    c = Contradiction(1, 2);

    c.addHLinePattern(1, 0, Edge.LINE);
    c.addHLinePattern(1, 1, Edge.LINE);
    c.addVLinePattern(0, 1, Edge.LINE);
  } else if (i == 2) {
    /**
     * Contradiction #03
     * . _ .
     * |   |
     * . _ .
     */
    c = Contradiction(1, 1);

    c.addHLinePattern(0, 0, Edge.LINE);
    c.addVLinePattern(0, 0, Edge.LINE);
    c.addHLinePattern(1, 0, Edge.LINE);
    c.addVLinePattern(0, 1, Edge.LINE);
  } else if (i == 3) {
    /**
     * Contradiction #04
     * . x .
     * x 3
     * .   .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.THREE);
    c.addHLinePattern(0, 0, Edge.NLINE);
    c.addVLinePattern(0, 0, Edge.NLINE);
  } else if (i == 4) {
    /**
     * Contradiction #05
     * .   .
     * x 3 x
     * .   .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.THREE);
    c.addVLinePattern(0, 0, Edge.NLINE);
    c.addVLinePattern(0, 1, Edge.NLINE);
  } else if (i == 5) {
    /**
     * Contradiction #06
     * . _ .
     * | 2
     * . _ .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.TWO);
    c.addHLinePattern(0, 0, Edge.LINE);
    c.addHLinePattern(1, 0, Edge.LINE);
    c.addVLinePattern(0, 0, Edge.LINE);
  } else if (i == 6) {
    /**
     * Contradiction #07
     * . x .
     * x 2
     * . x .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.TWO);
    c.addHLinePattern(0, 0, Edge.NLINE);
    c.addHLinePattern(1, 0, Edge.NLINE);
    c.addVLinePattern(0, 0, Edge.NLINE);
  } else if (i == 7) {
    /**
     * Contradiction #08
     * . _ .
     * | 1
     * .   .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.ONE);
    c.addHLinePattern(0, 0, Edge.LINE);
    c.addVLinePattern(0, 0, Edge.LINE);
  } else if (i == 8) {
    /**
     * Contradiction #09
     * .   .
     * | 1 |
     * .   .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.ONE);
    c.addVLinePattern(0, 0, Edge.LINE);
    c.addVLinePattern(0, 1, Edge.LINE);
  } else if (i == 9) {
    /**
     * Contradiction #10
     * . x .
     * x 1 x
     * . x .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.ONE);
    c.addVLinePattern(0, 0, Edge.NLINE);
    c.addVLinePattern(0, 1, Edge.NLINE);
    c.addHLinePattern(0, 0, Edge.NLINE);
    c.addHLinePattern(1, 0, Edge.NLINE);
  } else if (i == 10) {
    /**
     * Contradiction #11
     * .   .
     * | 0
     * .   .
     */
    c = Contradiction(1, 1);

    c.addNumberPattern(0, 0, Number.ZERO);
    c.addVLinePattern(0, 0, Edge.LINE);
  } else {
    c = empty_contradiction;
  }

  return c;
}
