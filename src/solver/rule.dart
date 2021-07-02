import '../shared/enums.dart';
import '../shared/structs.dart';

class Rule {
  final int _m;
  final int _n;

  final List<NumberPosition> _numberPattern = <NumberPosition>[];
  final List<EdgePosition> _hLinePattern = <EdgePosition>[];
  final List<EdgePosition> _vLinePattern = <EdgePosition>[];
  final List<EdgePosition> _hLineDiff = <EdgePosition>[];
  final List<EdgePosition> _vLineDiff = <EdgePosition>[];

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

  List<EdgePosition> get hLineDiff {
    return _hLineDiff;
  }

  List<EdgePosition> get vLineDiff {
    return _vLineDiff;
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

  void addHLineDiff(int i, int j, Edge edge) {
    _hLineDiff.add(EdgePosition(Coordinates(i, j), edge));
  }

  void addVLineDiff(int i, int j, Edge edge) {
    _vLineDiff.add(EdgePosition(Coordinates(i, j), edge));
  }

  Rule(this._m, this._n);

/* Gives the height of the number grid based on a given
 * orientation. In its upright position, its height is m_. */
  int getNumberHeight(Orientation orient) {
    switch (orient) {
      case Orientation.UP:
      case Orientation.DOWN:
      case Orientation.UPFLIP:
      case Orientation.DOWNFLIP:
        return _m;
      case Orientation.LEFT:
      case Orientation.RIGHT:
      case Orientation.LEFTFLIP:
      case Orientation.RIGHTFLIP:
        return _n;
    }
  }

/* Gives the width of the number grid based on a given
 * orientation. In its upright position, its width is n_. */
  int getNumberWidth(Orientation orient) {
    switch (orient) {
      case Orientation.UP:
      case Orientation.DOWN:
      case Orientation.UPFLIP:
      case Orientation.DOWNFLIP:
        return _n;
      case Orientation.LEFT:
      case Orientation.RIGHT:
      case Orientation.LEFTFLIP:
      case Orientation.RIGHTFLIP:
        return _m;
    }
  }
}
