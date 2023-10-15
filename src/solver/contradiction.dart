import '../shared/enums.dart';
import '../shared/structs.dart';

class Contradiction {
  final int _m;
  final int _n;

  final List<NumberPosition> _numberPattern = <NumberPosition>[];
  final List<EdgePosition> _hLinePattern = <EdgePosition>[];
  final List<EdgePosition> _vLinePattern = <EdgePosition>[];

  int get height {
    return _m;
  }

  int get width {
    return _n;
  }

  List<NumberPosition> get numberPattern {
    return _numberPattern;
  }

  List<EdgePosition> get hLinePattern {
    return _hLinePattern;
  }

  List<EdgePosition> get vLinePattern {
    return _vLinePattern;
  }

  void addNumberPattern(int i, int j, Number num) {
    _numberPattern.add(NumberPosition(Coordinates(i, j), num));
  }

  void addHLinePattern(int i, int j, Edge edge) {
    _hLinePattern.add(EdgePosition(Coordinates(i, j), edge));
  }

  void addVLinePattern(int i, int j, Edge edge) {
    _vLinePattern.add(EdgePosition(Coordinates(i, j), edge));
  }

  Contradiction(this._m, this._n);

/* Gives the height of the number grid based on a given
 * orientation. In its upright position, its height is m_.
 * These functions all seem unnecessary for contradictions
 * since I believe they are all square in terms of dimensions. */
  int getNumberHeight(Orientation orient) {
    switch (orient) {
      case Orientation.up:
      case Orientation.down:
      case Orientation.upFlip:
      case Orientation.downFlip:
        return _m;
      case Orientation.left:
      case Orientation.right:
      case Orientation.leftFlip:
      case Orientation.rightFlip:
        return _n;
    }
  }

/* Gives the width of the number grid based on a given
 * orientation. In its upright position, its width is n_. */
  int getNumberWidth(Orientation orient) {
    switch (orient) {
      case Orientation.up:
      case Orientation.down:
      case Orientation.upFlip:
      case Orientation.downFlip:
        return _n;
      case Orientation.left:
      case Orientation.right:
      case Orientation.leftFlip:
      case Orientation.rightFlip:
        return _m;
    }
  }
}
