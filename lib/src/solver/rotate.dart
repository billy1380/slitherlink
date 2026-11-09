import '../shared/enums.dart';
import '../shared/structs.dart';

/* Translates coordinates for a number on a lattice in a
 * given orientation to the coordinates for that number
 * in its canonical orientation and returns the new
 * adjusted coordinates. */
Coordinates rotateNumber(int i, int j, int m, int n, Orientation orient) {
  switch (orient) {
    case Orientation.upFlip:
      i = m - i - 1;
      continue up;
    up:
    case Orientation.up:
      return Coordinates(i, j);
    case Orientation.downFlip:
      i = m - i - 1;
      continue down;
    down:
    case Orientation.down:
      return Coordinates(m - i - 1, n - j - 1);
    case Orientation.leftFlip:
      i = m - i - 1;
      continue left;
    left:
    case Orientation.left:
      return Coordinates(n - j - 1, i);
    case Orientation.rightFlip:
      i = m - i - 1;
      continue right;
    right:
    case Orientation.right:
      return Coordinates(j, m - i - 1);
  }
}

/* Translates coordinates for a horizontal edge on a
 * lattice in a given orientation to the coordinates
 * for that edge in its canonical orientation and
 * returns the new adjusted coordinates. */
Coordinates rotateHLine(int i, int j, int m, int n, Orientation orient) {
  return rotateNumber(i, j, m + 1, n, orient);
}

/* Translates coordinates for a vertical edge on a
 * lattice in a given orientation to the coordinates
 * for that edge in its canonical orientation and
 * returns the new adjusted coordinates. */
Coordinates rotateVLine(int i, int j, int m, int n, Orientation orient) {
  return rotateNumber(i, j, m, n + 1, orient);
}
