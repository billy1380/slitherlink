import '../shared/enums.dart';
import '../shared/structs.dart';

class Contradiction {
  int m_;
  int n_;

  List<NumberPosition> numberPattern_ = [];
  List<EdgePosition> hLinePattern_ = [];
  List<EdgePosition> vLinePattern_ = [];

  int get height {
    return m_;
  }

  int get width {
    return n_;
  }

  List<NumberPosition> get numberPattern {
    return numberPattern_;
  }

  List<EdgePosition> get hLinePattern {
    return hLinePattern_;
  }

  List<EdgePosition> get vLinePattern {
    return vLinePattern_;
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

  Contradiction(this.m_, this.n_);

/* Gives the height of the number grid based on a given
 * orientation. In its upright position, its height is m_.
 * These functions all seem unnecessary for contradictions
 * since I believe they are all square in terms of dimensions. */
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
