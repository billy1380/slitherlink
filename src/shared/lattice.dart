import 'enums.dart';

const String point = '.';
const String hline = '-';
const String vline = '|';
const String ex = 'x';
const String blank = ' ';

class Lattice {
  bool updated = true;

  bool init_ = false;

  late int m_; /* number of rows */
  late int n_; /* number of columns */
  late List<List<Number>> numbers_;
  late List<List<Edge>> hlines_;
  late List<List<Edge>> vlines_;

  int get height {
    return m_;
  }

  int get width {
    return n_;
  }

/* Initializes the three two dimensional arrays used to
 * represent a lattice, one each for numbers, horizontal
 * lines, and vertical lines. Sets the init_ variable to
 * true so that the destructor knows to free the memory
 * after destroying an instance of the class. */
  void initArrays(int m, int n) {
    assert(m > 0 && n > 0);

    m_ = m;
    n_ = n;

    numbers_ =
        List<List<Number>>.filled(m_, List<Number>.filled(n_, Number.NONE));
    hlines_ =
        List<List<Edge>>.filled(m_ + 1, List<Edge>.filled(n_, Edge.EMPTY));
    vlines_ =
        List<List<Edge>>.filled(m_, List<Edge>.filled(n_ + 1, Edge.EMPTY));

    init_ = true;

    _cleanArrays();
  }

/* Get value of number located at coordinates (i, j),
 * where i is on the range [0, m_+1] and j is on the
 * range [0, n_]. */
  Number getNumber(int i, int j) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_);

    return numbers_[i][j];
  }

/* Get value of horizontal edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  Edge getHLine(int i, int j) {
    assert(0 <= i && i < m_ + 1 && 0 <= j && j < n_);

    return hlines_[i][j];
  }

/* Get value of vertical edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  Edge getVLine(int i, int j) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_ + 1);

    return vlines_[i][j];
  }

/* Get value of horizontal edge located at coordinates
 * (i, j), with no restriction on where they can be obtained. */
  Edge checkEdgeH(int i, int j) {
    return hlines_[i][j];
  }

/* Get value of vertical edge located at coordinates
 * (i, j), with no restriction on where they can be obtained. */
  Edge checkEdgeV(int i, int j) {
    return vlines_[i][j];
  }

/* Set value of number located at coordinates (i, j),
 * where i is on the range [0, m_+1] and j is on the
 * range [0, n_]. */
  void setNumber(int i, int j, Number num) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_);

    numbers_[i][j] = num;
  }

/* Set value of horizontal edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  bool setHLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ + 1 && 0 <= j && j < n_);

    hlines_[i][j] = edge;
    return true;
  }

/* Set value of vertical edge located at coordinates
 * (i, j), where i is on the range [0, m_+1] and j is
 * on the range [0, n_]. */
  bool setVLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_ + 1);

    vlines_[i][j] = edge;
    return true;
  }

/* Wipes out all data from the three two dimensional
 * arrays so that new data can be added on top of a
 * clean grid. */
  void _cleanArrays() {
    if (init_) {
      for (int i = 0; i < m_; i++) {
        for (int j = 0; j < n_; j++) {
          numbers_[i][j] = Number.NONE;
          hlines_[i][j] = Edge.EMPTY;
          vlines_[i][j] = Edge.EMPTY;
        }
        vlines_[i][n_] = Edge.EMPTY;
      }

      for (int j = 0; j < n_; j++) {
        hlines_[m_][j] = Edge.EMPTY;
      }
    }
  }
}
