import 'dart:math';

import 'enums.dart';
import 'lattice.dart';

class Grid extends Lattice {
  late List<List<bool>> _updateMatrix;
  late List<List<bool>> _contraMatrix;
  late List<List<MapEntry<int, int>>> _contourMatrix;
  bool _valid = true;
  late int _numOpenLoops;
  late int _numClosedLoops;

  @override
  void initArrays(int m, int n) {
    super.initArrays(m, n);

    init_ = false;
  }

  bool get valid {
    return _valid;
  }

  set valid(bool validity) {
    _valid = validity && _valid;
  }

  bool getUpdateMatrix(int i, int j) {
    return _updateMatrix[i][j];
  }

  bool getContraMatrix(int i, int j) {
    return _contraMatrix[i][j];
  }

  void setUpdateMatrix(int i, int j, bool b) {
    _updateMatrix[i][j] = b;
  }

  void setContraMatrix(int i, int j, bool b) {
    _contraMatrix[i][j] = b;
  }

  MapEntry<int, int> _getContourMatrix(int i, int j) {
    return _contourMatrix[i][j];
  }

  void _setContourMatrix(int i, int j, MapEntry<int, int> p) {
    _contourMatrix[i][j] = p;
  }

  void resetGrid() {
    for (int i = 1; i < height; i++) {
      for (int j = 1; j < width - 1; j++) {
        hlines[i][j] = Edge.empty;
      }
    }

    for (int i = 1; i < height - 1; i++) {
      for (int j = 1; j < width; j++) {
        vlines[i][j] = Edge.empty;
      }
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        setUpdateMatrix(i, j, true);
        setContraMatrix(i, j, true);
      }
    }

    for (int i = 0; i < height + 1; i++) {
      for (int j = 0; j < width + 1; j++) {
        _setContourMatrix(i, j, MapEntry<int, int>(-1, -1));
      }
    }

    _numClosedLoops = 0;
    _numOpenLoops = 0;
  }

/*
 * Copies grid for the purpose of making a guess.
 */
  void copy(Grid newGrid) {
    newGrid.initArrays(height, width);
    newGrid.initUpdateMatrix();

    for (int i = 0; i < height + 1; i++) {
      for (int j = 0; j < width; j++) {
        newGrid.changeHLine(i, j, getHLine(i, j));
      }
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width + 1; j++) {
        newGrid.changeVLine(i, j, getVLine(i, j));
      }
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        newGrid.setNumber(i, j, getNumber(i, j));
        newGrid.setUpdateMatrix(i, j, _updateMatrix[i][j]);
        newGrid.setContraMatrix(i, j, _contraMatrix[i][j]);
      }
    }

    for (int i = 0; i < height + 1; i++) {
      for (int j = 0; j < width + 1; j++) {
        newGrid._setContourMatrix(i, j, _contourMatrix[i][j]);
      }
    }

    newGrid._numOpenLoops = _numOpenLoops;
    newGrid._numClosedLoops = _numClosedLoops;
  }

  void clearAndCopy(Grid newGrid) {
    for (int i = 0; i < height + 1; i++) {
      for (int j = 0; j < width; j++) {
        newGrid.changeHLine(i, j, getHLine(i, j));
      }
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width + 1; j++) {
        newGrid.changeVLine(i, j, getVLine(i, j));
      }
    }

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        newGrid.setNumber(i, j, getNumber(i, j));
        newGrid.setUpdateMatrix(i, j, _updateMatrix[i][j]);
        newGrid.setContraMatrix(i, j, _contraMatrix[i][j]);
      }
    }

    for (int i = 0; i < height + 1; i++) {
      for (int j = 0; j < width + 1; j++) {
        newGrid._setContourMatrix(i, j, _contourMatrix[i][j]);
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
    assert(0 <= i && i < m + 1 && 0 <= j && j < n);

    if (edge == Edge.empty) {
      return true;
    }

    Edge prevEdge = getHLine(i, j);
    if (prevEdge == Edge.empty) {
      hlines[i][j] = edge;
    } else if (prevEdge != edge) {
      return false;
    } else if (prevEdge == edge) {
      return true;
    }

    // Update contour information
    if (edge == Edge.line) {
      _updateContourMatrix(i, j, true);
    }

    // Update which parts of grid have possible rules that could be applied
    for (int x = max(0, i - 3); x < min(i + 1, height); x++) {
      for (int y = max(0, j - 2); y < min(j + 1, width); y++) {
        _updateMatrix[x][y] = true;
      }
    }

    // Update which parts of grid have possible contradictions
    for (int x = max(0, i - 2); x < min(i + 1, height); x++) {
      for (int y = max(0, j - 1); y < min(j + 1, width); y++) {
        _contraMatrix[x][y] = true;
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
    assert(0 <= i && i < m && 0 <= j && j < n + 1);

    Edge prevEdge = getVLine(i, j);
    if (prevEdge == Edge.empty) {
      vlines[i][j] = edge;
    } else if (prevEdge != edge) {
      return false;
    } else if (prevEdge == edge) {
      return true;
    }

    // Update contour information
    if (edge == Edge.line) {
      _updateContourMatrix(i, j, false);
    }

    // Update which parts of grid have possible rules that could be applied
    for (int x = max(0, i - 2); x < min(i + 1, height); x++) {
      for (int y = max(0, j - 3); y < min(j + 1, width); y++) {
        _updateMatrix[x][y] = true;
      }
    }

    // Update which parts of grid have possible contradictions
    for (int x = max(0, i - 1); x < min(i + 1, height); x++) {
      for (int y = max(0, j - 2); y < min(j + 1, width); y++) {
        _contraMatrix[x][y] = true;
      }
    }

    return true;
  }

/*
 * Set a horizontal line to a given edge type, but allows overwrites.
 * Intended for the purpose of puzzle creation.
 */
  bool changeHLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m + 1 && 0 <= j && j < n);

    hlines[i][j] = edge;

    return true;
  }

/*
 * Set a vertical line to a given edge type, but allows overwrites.
 * Intended for the purpose of puzzle creation.
 */
  bool changeVLine(int i, int j, Edge edge) {
    assert(0 <= i && i < m && 0 <= j && j < n + 1);

    vlines[i][j] = edge;

    return true;
  }

/*
 * Check whether a given number has been satisfied with the proper number of lines
 * surrounding it.
 */
  bool numberSatisfied(int i, int j) {
    assert(0 <= i && i < m && 0 <= j && j < n);

    Number number = numbers[i][j];

    /* determine number of lines around number */
    int numLines = (hlines[i][j] == Edge.line ? 1 : 0) +
        (hlines[i + 1][j] == Edge.line ? 1 : 0) +
        (vlines[i][j] == Edge.line ? 1 : 0) +
        (vlines[i][j + 1] == Edge.line ? 1 : 0);

    switch (number) {
      case Number.none:
        return true;
      case Number.zero:
        return numLines == 0;
      case Number.one:
        return numLines == 1;
      case Number.two:
        return numLines == 2;
      case Number.three:
        return numLines == 3;
    }
  }

/*
 * Checks if the puzzle is solved by assuring that there is only one contour
 * and that each number has been satisfied
 */
  bool get isSolved {
    if (_numOpenLoops != 0 || _numClosedLoops != 1) {
      return false;
    }

    for (int i = 0; i < m; i++) {
      for (int j = 0; j < n; j++) {
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
  bool get containsClosedContours {
    return (_numClosedLoops > 0);
  }

  void initUpdateMatrix() {
    if (!init_) {
      _updateMatrix = List<List<bool>>.generate(
          m, (int i) => List<bool>.generate(n, (int j) => true));

      _contraMatrix = List<List<bool>>.generate(
          m, (int i) => List<bool>.generate(n, (int j) => false));

      _contourMatrix = List<List<MapEntry<int, int>>>.generate(
          m + 1,
          (int i) => List<MapEntry<int, int>>.generate(
              n + 1, (int j) => MapEntry<int, int>(-1, -1)));

      _numOpenLoops = 0;
      _numClosedLoops = 0;
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
      _numClosedLoops++;
      _numOpenLoops--;
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
      _numOpenLoops--;
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
      _numOpenLoops++;
    }
  }
}
