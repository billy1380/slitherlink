import '../shared/enums.dart';
import '../shared/grid.dart';
import '../shared/random.dart';
import '../shared/structs.dart';

class LoopGen {
  late List<List<LoopCell>> _loop;
  final Grid _grid;
  final int _m;
  final int _n;

  LoopGen(this._m, this._n, this._grid);

  void generate() {
    _initArray();
    _genLoop();
    _fillGrid();
  }

/* fill the grid with numbers after generating the loop */
  void _fillGrid() {
    int lines;
    for (int i = 1; i < _m + 1; i++) {
      for (int j = 1; j < _n + 1; j++) {
        lines = _countLines(i - 1, j - 1);

        switch (lines) {
          case 0:
            _grid.setNumber(i, j, Number.zero);
            break;
          case 1:
            _grid.setNumber(i, j, Number.one);
            break;
          case 2:
            _grid.setNumber(i, j, Number.two);
            break;
          case 3:
            _grid.setNumber(i, j, Number.three);
            break;
        }
      }
    }
  }

/* count the number of lines adjacent to a given cell */
  int _countLines(int i, int j) {
    bool inside = _inLoop(i, j);

    int lines = ((!_inBounds(Coordinates(i + 1, j)) && inside) ||
                (_inBounds(Coordinates(i + 1, j)) &&
                    _inLoop(i + 1, j) != inside)
            ? 1
            : 0) +
        ((!_inBounds(Coordinates(i - 1, j)) && inside) ||
                (_inBounds(Coordinates(i - 1, j)) &&
                    _inLoop(i - 1, j) != inside)
            ? 1
            : 0) +
        ((!_inBounds(Coordinates(i, j + 1)) && inside) ||
                (_inBounds(Coordinates(i, j + 1)) &&
                    _inLoop(i, j + 1) != inside)
            ? 1
            : 0) +
        ((!_inBounds(Coordinates(i, j - 1)) && inside) ||
                (_inBounds(Coordinates(i, j - 1)) &&
                    _inLoop(i, j - 1) != inside)
            ? 1
            : 0);

    return lines;
  }

/* check whether a particular cell is inside the loop */
  bool _inLoop(int i, int j) {
    return _loop[i][j] == LoopCell.exp || _loop[i][j] == LoopCell.noExp;
  }

/* allocate memory for creating loop */
  void _initArray() {
    _loop = List<List<LoopCell>>.generate(
        _m, (int i) => List<LoopCell>.filled(_n, LoopCell.unknown));
  }

/* Fill grid entirely with numbers that make a loop */
  void _genLoop() {
    Coordinates cur = Coordinates(_m ~/ 2, _n ~/ 2);
    Coordinates next;
    List<Coordinates> avail = <Coordinates>[
      cur,
    ];

    while (avail.isNotEmpty) {
      cur = _pickCell(avail);

      if (cur.i == -1 || cur.j == -1) {
        return;
      }

      next = _addCell(cur);

      if (_loop[cur.i][cur.j] == LoopCell.exp) {
        _addAvailable(cur, avail);
      }
      if (_loop[next.i][next.j] == LoopCell.exp) {
        _addAvailable(next, avail);
      }
    }
  }

/* add a cell branching of from an existing cell */
  Coordinates _addCell(Coordinates cur) {
    assert(cur.i >= 0 && cur.i < _m && cur.j >= 0 && cur.j < _n);

    /* check whether it's possible to expand in any direction */
    if (!_isExpandable(cur)) {
      return cur;
    }

    /* pick some direction up/down/left/right from cur */
    Coordinates newpos = _pickDirection(cur);

    /* and verify it's a valid choice */
    if (!_inBounds(newpos) || _loop[newpos.i][newpos.j] != LoopCell.unknown) {
      return cur;
    }

    AdjacencyList adjacencyList = _getAdjacent(newpos);

    if (!adjacencyList.u &&
        !adjacencyList.d &&
        !adjacencyList.l &&
        !adjacencyList.r) {
      _loop[newpos.i][newpos.j] = LoopCell.out;
      return newpos;
    }

    _loop[newpos.i][newpos.j] =
        (_validCell(newpos, cur)) ? LoopCell.exp : LoopCell.out;
    return newpos;
  }

/* pick some direction up/down/left/right from cur */
  Coordinates _pickDirection(Coordinates cur) {
    int vert = r.nextInt(3) - 1;
    int hor = 0;

    if (vert == 0) {
      hor = (r.nextInt(2) * 2) - 1;
    }

    return Coordinates(cur.i + vert, cur.j + hor);
  }

/* check whether it's possible to expand in at least one direction */
  bool _isExpandable(Coordinates cur) {
    assert(cur.i >= 0 && cur.i < _m && cur.j >= 0 && cur.j < _n);

    AdjacencyList adjacencyList = _getAdjacent(cur);

    if (!adjacencyList.u &&
        !adjacencyList.d &&
        !adjacencyList.l &&
        !adjacencyList.r) {
      _loop[cur.i][cur.j] = LoopCell.noExp;
      return false;
    }

    return true;
  }

/* Return which cells relative to the current cell are available */
  AdjacencyList _getAdjacent(Coordinates cur) {
    AdjacencyList adjacencyList = AdjacencyList(
        u: _validCell(Coordinates(cur.i - 1, cur.j), cur),
        d: _validCell(Coordinates(cur.i + 1, cur.j), cur),
        l: _validCell(Coordinates(cur.i, cur.j - 1), cur),
        r: _validCell(Coordinates(cur.i, cur.j + 1), cur));
    return adjacencyList;
  }

/* Adds a cell to the vector of available cells, if it is not already in the vector */
  void _addAvailable(Coordinates coords, List<Coordinates> avail) {
    for (int i = 0; i < avail.length; i++) {
      if (avail[i].i == coords.i && avail[i].j == coords.j) {
        return;
      }
    }

    avail.add(coords);
  }

/* pick a cell adjacent to the current one--up, down, left, or right */
  Coordinates _pickCell(List<Coordinates> avail) {
    Coordinates guess;

    if (avail.isNotEmpty) {
      int guessindex = r.nextInt(avail.length);
      guess = avail.removeAt(guessindex);
      return guess;
    } else {
      return Coordinates(-1, -1);
    }
  }

/* Don't change this function, David. Like really, don't. */
  bool _validCell(Coordinates coords, Coordinates cur) {
    bool valid = true;

    /* check to make sure the cell is within the grid */
    if (!_inBounds(coords)) {
      return false;
    }

    valid = valid && _loop[coords.i][coords.j] != LoopCell.noExp;
    valid = valid && _loop[coords.i][coords.j] != LoopCell.out;
    valid = valid && _loop[coords.i][coords.j] != LoopCell.exp;

    Coordinates shift = Coordinates(coords.i - cur.i, coords.j - cur.j);

    if ((shift.i + shift.j != 1 && shift.i + shift.j != -1) ||
        shift.i * shift.j != 0) {
      valid = false;
    }

    if (shift.i == 0) {
      valid = valid && _cellOpen(coords.i, coords.j + shift.j);

      if (coords.i == 0) {
        valid = valid && _cellOpen(1, coords.j + shift.j);
      } else if (coords.i == _m - 1) {
        valid = valid && _cellOpen(_m - 2, coords.j + shift.j);
      }
      valid = valid && _cellOpen(coords.i + 1, coords.j + shift.j);
      valid = valid && _cellOpen(coords.i - 1, coords.j + shift.j);
    }

    if (shift.j == 0) {
      valid = valid && _cellOpen(coords.i + shift.i, coords.j);

      if (coords.j == 0) {
        valid = valid && _cellOpen(coords.i + shift.i, 1);
      } else if (coords.j == _n - 1) {
        valid = valid && _cellOpen(coords.i + shift.i, _n - 2);
      }
      valid = valid && _cellOpen(coords.i + shift.i, coords.j + 1);
      valid = valid && _cellOpen(coords.i + shift.i, coords.j - 1);
    }

    if (!valid && _loop[coords.i][coords.j] == LoopCell.unknown) {
      _loop[coords.i][coords.j] = LoopCell.out;
    }

    return valid;
  }

/* check whether a cell (or, potentially, noncell) is inside the loop */
  bool _cellOpen(int i, int j) {
    Coordinates coords = Coordinates(i, j);
    return !_inBounds(coords) ||
        _loop[coords.i][coords.j] == LoopCell.unknown ||
        _loop[coords.i][coords.j] == LoopCell.out;
  }

/* check whether a particular set of coordinates are within the bounds of the grid */
  bool _inBounds(Coordinates coords) {
    return coords.i >= 0 && coords.j >= 0 && coords.i < _m && coords.j < _n;
  }
}
