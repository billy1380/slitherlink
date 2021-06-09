import 'dart:math';

import 'enums.dart';
import 'lattice.dart';

class Grid extends Lattice {
  late List<List<bool>> updateMatrix_;
  late List<List<bool>> contraMatrix_;
  late List<List<MapEntry<int, int>>> contourMatrix_;
  bool valid_ = true;
  late int numOpenLoops_;
  late int numClosedLoops_;

  @override
  void initArrays(int m, int n) {
    super.initArrays(m, n);

    init_ = false;
  }

  bool getValid() {
    return valid_;
  }

  void setValid(bool validity) {
    valid_ = validity && valid_;
  }

  bool getUpdateMatrix(int i, int j) {
    return updateMatrix_[i][j];
  }

  bool getContraMatrix(int i, int j) {
    return contraMatrix_[i][j];
  }

  void setUpdateMatrix(int i, int j, bool b) {
    updateMatrix_[i][j] = b;
  }

  void setContraMatrix(int i, int j, bool b) {
    contraMatrix_[i][j] = b;
  }

  MapEntry<int, int> _getContourMatrix(int i, int j) {
    return contourMatrix_[i][j];
  }

  void _setContourMatrix(int i, int j, MapEntry<int, int> p) {
    contourMatrix_[i][j] = p;
  }

  void resetGrid() {
    for (int i = 1; i < getHeight(); i++) {
      for (int j = 1; j < getWidth() - 1; j++) {
        hlines_[i][j] = Edge.EMPTY;
      }
    }

    for (int i = 1; i < getHeight() - 1; i++) {
      for (int j = 1; j < getWidth(); j++) {
        vlines_[i][j] = Edge.EMPTY;
      }
    }

    for (int i = 0; i < getHeight(); i++) {
      for (int j = 0; j < getWidth(); j++) {
        setUpdateMatrix(i, j, true);
        setContraMatrix(i, j, true);
      }
    }

    for (int i = 0; i < getHeight() + 1; i++) {
      for (int j = 0; j < getWidth() + 1; j++) {
        _setContourMatrix(i, j, MapEntry<int, int>(-1, -1));
      }
    }

    numClosedLoops_ = 0;
    numOpenLoops_ = 0;
  }

/*
 * Copies grid for the purpose of making a guess.
 */
  void copy(Grid newGrid) {
    newGrid.initArrays(getHeight(), getWidth());
    newGrid.initUpdateMatrix();

    for (int i = 0; i < getHeight() + 1; i++) {
      for (int j = 0; j < getWidth(); j++) {
        newGrid.changeHLine(i, j, getHLine(i, j));
      }
    }

    for (int i = 0; i < getHeight(); i++) {
      for (int j = 0; j < getWidth() + 1; j++) {
        newGrid.changeVLine(i, j, getVLine(i, j));
      }
    }

    for (int i = 0; i < getHeight(); i++) {
      for (int j = 0; j < getWidth(); j++) {
        newGrid.setNumber(i, j, getNumber(i, j));
        newGrid.setUpdateMatrix(i, j, updateMatrix_[i][j]);
        newGrid.setContraMatrix(i, j, contraMatrix_[i][j]);
      }
    }

    for (int i = 0; i < getHeight() + 1; i++) {
      for (int j = 0; j < getWidth() + 1; j++) {
        newGrid._setContourMatrix(i, j, contourMatrix_[i][j]);
      }
    }

    newGrid.numOpenLoops_ = numOpenLoops_;
    newGrid.numClosedLoops_ = numClosedLoops_;
  }

  void clearAndCopy(Grid newGrid) {
    for (int i = 0; i < getHeight() + 1; i++) {
      for (int j = 0; j < getWidth(); j++) {
        newGrid.changeHLine(i, j, getHLine(i, j));
      }
    }

    for (int i = 0; i < getHeight(); i++) {
      for (int j = 0; j < getWidth() + 1; j++) {
        newGrid.changeVLine(i, j, getVLine(i, j));
      }
    }

    for (int i = 0; i < getHeight(); i++) {
      for (int j = 0; j < getWidth(); j++) {
        newGrid.setNumber(i, j, getNumber(i, j));
        newGrid.setUpdateMatrix(i, j, updateMatrix_[i][j]);
        newGrid.setContraMatrix(i, j, contraMatrix_[i][j]);
      }
    }

    for (int i = 0; i < getHeight() + 1; i++) {
      for (int j = 0; j < getWidth() + 1; j++) {
        newGrid._setContourMatrix(i, j, contourMatrix_[i][j]);
      }
    }
  }

/*;
 * Set a horizontal line to a given edge type, checking to see if this change overwrites
 * any previous value set to that position. If a line is added, create a new contour and
 * attempt to merge that contour to any adjacent contours.
 */
  @override
  bool setHLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ + 1 && 0 <= j && j < n_);

    if (edge == Edge.EMPTY) {
      return true;
    }

    Edge prevEdge = getHLine(i, j);
    if (prevEdge == Edge.EMPTY) {
      hlines_[i][j] = edge;
    } else if (prevEdge != edge) {
      return false;
    } else if (prevEdge == edge) {
      return true;
    }

    // Update contour information
    if (edge == Edge.LINE) {
      _updateContourMatrix(i, j, true);
    }

    // Update which parts of grid have possible rules that could be applied
    for (int x = max(0, i - 3); x < min(i + 1, getHeight()); x++) {
      for (int y = max(0, j - 2); y < min(j + 1, getWidth()); y++) {
        updateMatrix_[x][y] = true;
      }
    }

    // Update which parts of grid have possible contradictions
    for (int x = max(0, i - 2); x < min(i + 1, getHeight()); x++) {
      for (int y = max(0, j - 1); y < min(j + 1, getWidth()); y++) {
        contraMatrix_[x][y] = true;
      }
    }

    return true;
  }

/*
 * Set a vertical line to a given edge type, checking to see if this change overwrites
 * any previous value set to that position. If a line is added, create a new contour and
 * attempt to merge that contour to any adjacent contours.
 */
  @override
  bool setVLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_ + 1);

    Edge prevEdge = getVLine(i, j);
    if (prevEdge == Edge.EMPTY) {
      vlines_[i][j] = edge;
    } else if (prevEdge != edge) {
      return false;
    } else if (prevEdge == edge) {
      return true;
    }

    // Update contour information
    if (edge == Edge.LINE) {
      _updateContourMatrix(i, j, false);
    }

    // Update which parts of grid have possible rules that could be applied
    for (int x = max(0, i - 2); x < min(i + 1, getHeight()); x++) {
      for (int y = max(0, j - 3); y < min(j + 1, getWidth()); y++) {
        updateMatrix_[x][y] = true;
      }
    }

    // Update which parts of grid have possible contradictions
    for (int x = max(0, i - 1); x < min(i + 1, getHeight()); x++) {
      for (int y = max(0, j - 2); y < min(j + 1, getWidth()); y++) {
        contraMatrix_[x][y] = true;
      }
    }

    return true;
  }

/*
 * Set a horizontal line to a given edge type, but allows overwrites.
 * Intended for the purpose of puzzle creation.
 */
  bool changeHLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ + 1 && 0 <= j && j < n_);

    hlines_[i][j] = edge;

    return true;
  }

/*
 * Set a vertical line to a given edge type, but allows overwrites.
 * Intended for the purpose of puzzle creation.
 */
  bool changeVLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_ + 1);

    vlines_[i][j] = edge;

    return true;
  }

/*
 * Check whether a given number has been satisfied with the proper number of lines
 * surrounding it.
 */
  bool numberSatisfied(int i, int j) {
    assert(0 <= i && i < m_ && 0 <= j && j < n_);

    Number number = numbers_[i][j];

    /* determine number of lines around number */
    int numLines = (hlines_[i][j] == Edge.LINE ? 1 : 0) +
        (hlines_[i + 1][j] == Edge.LINE ? 1 : 0) +
        (vlines_[i][j] == Edge.LINE ? 1 : 0) +
        (vlines_[i][j + 1] == Edge.LINE ? 1 : 0);

    switch (number) {
      case Number.NONE:
        return true;
      case Number.ZERO:
        return numLines == 0;
      case Number.ONE:
        return numLines == 1;
      case Number.TWO:
        return numLines == 2;
      case Number.THREE:
        return numLines == 3;
    }
  }

/*
 * Checks if the puzzle is solved by assuring that there is only one contour
 * and that each number has been satisfied
 */
  bool isSolved() {
    if (numOpenLoops_ != 0 || numClosedLoops_ != 1) {
      return false;
    }

    for (int i = 0; i < m_; i++) {
      for (int j = 0; j < n_; j++) {
        if (!numberSatisfied(i, j)) {
          return false;
        }
      }
    }

    return true;
  }

/*
 * Checks if there are any closed contours with the intention of detecting
 * prematurely closed contours
 */
  bool containsClosedContours() {
    return (numClosedLoops_ > 0);
  }

  void initUpdateMatrix() {
    if (!init_) {
      updateMatrix_ = List<List<bool>>.generate(
          m_, (i) => List<bool>.generate(n_, (j) => true));

      contraMatrix_ = List<List<bool>>.generate(
          m_, (i) => List<bool>.generate(n_, (j) => false));

      contourMatrix_ = List<List<MapEntry<int, int>>>.generate(
          m_ + 1,
          (index) => List<MapEntry<int, int>>.generate(
              n_ + 1, (j) => MapEntry<int, int>(-1, -1)));

      numOpenLoops_ = 0;
      numClosedLoops_ = 0;
    }

    init_ = true;
  }

/*
 * Updates the information on the endpoints of our contours according to what
 * new line has been added. We use this 2D array to keep track of the endpoints now
 * instead of a vector. Also keeps track of the current number of open
 * and closed loops in our grid
 */
  void _updateContourMatrix(int i, int j, bool hline) {
    int i2 = i;
    int j2 = j;

    // The second endpoint of the new line is determined by whether the line is
    // horizontal or vertical
    if (hline) {
      j2 = j + 1;
    } else {
      i2 = i + 1;
    }

    /* Both ends of the new line are already endpoints to a single contour.
       So get rid of both open endpoints and add one count of a closed loop. */
    if (_getContourMatrix(i, j).key == i2 &&
        _getContourMatrix(i, j).value == j2 &&
        _getContourMatrix(i2, j2).key == i &&
        _getContourMatrix(i2, j2).value == j) {
      _setContourMatrix(i, j, MapEntry<int, int>(-1, -1));
      _setContourMatrix(i2, j2, MapEntry<int, int>(-1, -1));
      numClosedLoops_++;
      numOpenLoops_--;
    }
    /* Both ends of the new line are already endpoints to two different
     * conoturs. Get rid of the open endpoints, update the new ends of the
     * merged contour, and count one less open contour */
    else if (_getContourMatrix(i, j).key != -1 &&
        _getContourMatrix(i2, j2).key != -1) {
      _setContourMatrix(_getContourMatrix(i, j).key,
          _getContourMatrix(i, j).value, _getContourMatrix(i2, j2));
      _setContourMatrix(_getContourMatrix(i2, j2).key,
          _getContourMatrix(i2, j2).value, _getContourMatrix(i, j));
      _setContourMatrix(i, j, MapEntry<int, int>(-1, -1));
      _setContourMatrix(i2, j2, MapEntry<int, int>(-1, -1));
      numOpenLoops_--;
    }
    /* First end of the new line is already an endpoint to a contour. Extend
     * the contour and update new endpoints. */
    else if (_getContourMatrix(i, j).key != -1) {
      _setContourMatrix(_getContourMatrix(i, j).key,
          _getContourMatrix(i, j).value, MapEntry<int, int>(i2, j2));
      _setContourMatrix(i2, j2, _getContourMatrix(i, j));
      _setContourMatrix(i, j, MapEntry<int, int>(-1, -1));
    }
    /* Second end of the new line is already an endpoint to a contour. Extend
     * the contour and update new endpoints. */
    else if (_getContourMatrix(i2, j2).key != -1) {
      _setContourMatrix(_getContourMatrix(i2, j2).key,
          _getContourMatrix(i2, j2).value, MapEntry<int, int>(i, j));
      _setContourMatrix(i, j, _getContourMatrix(i2, j2));
      _setContourMatrix(i2, j2, MapEntry<int, int>(-1, -1));
    }
    /* Neither end of new line is shared by a contour, so create a new contour
     * with endpoints (i,j) and (i,j+1) */
    else {
      _setContourMatrix(i, j, MapEntry<int, int>(i2, j2));
      _setContourMatrix(i2, j2, MapEntry<int, int>(i, j));
      numOpenLoops_++;
    }
  }
}
