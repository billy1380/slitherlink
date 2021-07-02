import 'enums.dart';

const String point = ".";
const String hline = "-";
const String vline = "|";
const String ex = "x";
const String blank = " ";

class Lattice {
  bool updated = true;

  bool init_ = false;

  late int m; /* number of rows */
  late int n; /* number of coluthis.ns */

  late List<List<Number>> numbers;
  late List<List<Edge>> hlines;
  late List<List<Edge>> vlines;

  int get height {
    return m;
  }

  int get width {
    return n;
  }

/* Initializes the three two dimensional arrays used to
 * represent a lattice, one each for numbers, horizontal
 * lines, and vertical lines. Sets the init_ variable to
 * true so that the destructor knows to free the memory
 * after destroying an instance of the class. */
  void initArrays(int m, int n) {
    assert(m > 0 && n > 0);

    this.m = m;
    this.n = n;

    numbers = List<List<Number>>.generate(
        this.m, (int i) => List<Number>.filled(this.n, Number.NONE));
    hlines = List<List<Edge>>.generate(
        this.m + 1, (int i) => List<Edge>.filled(this.n, Edge.EMPTY));
    vlines = List<List<Edge>>.generate(
        this.m, (int i) => List<Edge>.filled(this.n + 1, Edge.EMPTY));

    init_ = true;

    _cleanArrays();
  }

/* Get value of number located at coordinates (i, j),
 * where i is on the range [0, m_+1] and j is on the
 * range [0, n_]. */
  Number getNumber(int i, int j) {
    assert(0 <= i && i < m && 0 <= j && j < n);

    return numbers[i][j];
  }

/* Get value of horizontal edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  Edge getHLine(int i, int j) {
    assert(0 <= i && i < m + 1 && 0 <= j && j < n);

    return hlines[i][j];
  }

/* Get value of vertical edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  Edge getVLine(int i, int j) {
    assert(0 <= i && i < m && 0 <= j && j < n + 1);

    return vlines[i][j];
  }

/* Get value of horizontal edge located at coordinates
 * (i, j), with no restriction on where they can be obtained. */
  Edge checkEdgeH(int i, int j) {
    return hlines[i][j];
  }

/* Get value of vertical edge located at coordinates
 * (i, j), with no restriction on where they can be obtained. */
  Edge checkEdgeV(int i, int j) {
    return vlines[i][j];
  }

/* Set value of number located at coordinates (i, j),
 * where i is on the range [0, m_+1] and j is on the
 * range [0, n_]. */
  void setNumber(int i, int j, Number num) {
    assert(0 <= i && i < m && 0 <= j && j < n);

    numbers[i][j] = num;
  }

/* Set value of horizontal edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  bool setHLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m + 1 && 0 <= j && j < n);

    hlines[i][j] = edge;
    return true;
  }

/* Set value of vertical edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  bool setVLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m && 0 <= j && j < n + 1);

    vlines[i][j] = edge;
    return true;
  }

/* Wipes out all data from the three two dimensional
 * arrays so that new data can be added on top of a
 * clean grid. */
  void _cleanArrays() {
    if (init_) {
      for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
          numbers[i][j] = Number.NONE;
          hlines[i][j] = Edge.EMPTY;
          vlines[i][j] = Edge.EMPTY;
        }
        vlines[i][n] = Edge.EMPTY;
      }

      for (int j = 0; j < n; j++) {
        hlines[m][j] = Edge.EMPTY;
      }
    }
  }
}
