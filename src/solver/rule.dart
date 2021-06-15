import '../shared/enums.dart';
import '../shared/structs.dart';

class Rule {
  late int m_;
  late int n_;

  List<NumberPosition> numberPattern_ = [];
  List<EdgePosition> hLinePattern_ = [];
  List<EdgePosition> vLinePattern_ = [];
  List<EdgePosition> hLineDiff_ = [];
  List<EdgePosition> vLineDiff_ = [];

  int get height {
    return m_;
  }

  int get width {
    return n_;
  }

  List<NumberPosition> getNumberPattern() {
    return numberPattern_;
  }

  List<EdgePosition> getHLinePattern() {
    return hLinePattern_;
  }

  List<EdgePosition> getVLinePattern() {
    return vLinePattern_;
  }

  List<EdgePosition> getHLineDiff() {
    return hLineDiff_;
  }

  List<EdgePosition> getVLineDiff() {
    return vLineDiff_;
  }

  void addNumberPattern(int i, int j, Number num) {
    numberPattern_.add(NumberPosition(Coordinates(i, j), num));
  }

  void addHLinePattern(int i, int j, Edge edge) {
    hLinePattern_.add(EdgePosition(Coordinates(i, j), edge));
  }

  void addVLinePattern(int i, int j, Edge edge) {
    vLinePattern_.add(EdgePosition(Coordinates(i, j), edge));
  }

  void addHLineDiff(int i, int j, Edge edge) {
    hLineDiff_.add(EdgePosition(Coordinates(i, j), edge));
  }

  void addVLineDiff(int i, int j, Edge edge) {
    vLineDiff_.add(EdgePosition(Coordinates(i, j), edge));
  }

  Rule(this.m_, this.n_);

/* Gives the height of the number grid based on a given
 * orientation. In its upright position, its height is m_. */
  int getNumberHeight(Orientation orient) {
    switch (orient) {
      case Orientation.UP:
      case Orientation.DOWN:
      case Orientation.UPFLIP:
      case Orientation.DOWNFLIP:
        return m_;
      case Orientation.LEFT:
      case Orientation.RIGHT:
      case Orientation.LEFTFLIP:
      case Orientation.RIGHTFLIP:
        return n_;
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
        return n_;
      case Orientation.LEFT:
      case Orientation.RIGHT:
      case Orientation.LEFTFLIP:
      case Orientation.RIGHTFLIP:
        return m_;
    }
  }
}
