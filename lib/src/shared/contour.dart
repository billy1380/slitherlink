import 'structs.dart';

class Contour {
  int _length = 0;
  bool _closed = false;
  late Coordinates _start;
  late Coordinates _end;

  int get length {
    return _length;
  }

  bool get isClosed {
    return _closed;
  }

/* Initialize a contour with end points
 * (starti, startj) and (endi, endj) */
  Contour(int starti, int startj, int endi, int endj) {
    _start.i = starti;
    _start.j = startj;
    _end.i = endi;
    _end.j = endj;
    _length = 1;
  }

/* Checks whether the contour instance passed as
 * input shares an end point with this contour. */
  bool sharesEndpoint(Contour contour) {
    return ((_start.i == contour._start.i && _start.j == contour._start.j) ||
        (_start.i == contour._end.i && _start.j == contour._end.j) ||
        (_end.i == contour._start.i && _end.j == contour._start.j) ||
        (_end.i == contour._end.i && _end.j == contour._end.j));
  }

/* Add another contour as part of this contour. If
 * it doesn't share any endpoints, nothing happens.
 * Sets closed_ to true if new contour closes the
 * contour. */
  void addContour(Contour contour) {
    if (_start.i == contour._start.i && _start.j == contour._start.j) {
      _start.i = contour._end.i;
      _start.j = contour._end.j;
      _length++;
    } else if (_start.i == contour._end.i && _start.j == contour._end.j) {
      _start.i = contour._start.i;
      _start.j = contour._start.j;
      _length++;
    } else if (_end.i == contour._start.i && _end.j == contour._start.j) {
      _end.i = contour._end.i;
      _end.j = contour._end.j;
      _length++;
    } else if (_end.i == contour._end.i && _end.j == contour._end.j) {
      _end.i = contour._start.i;
      _end.j = contour._start.j;
      _length++;
    }

    if (_start.i == _end.i && _start.j == _end.j) {
      _closed = true;
    }
  }
}
