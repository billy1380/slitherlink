import 'enums.dart';
import 'lattice.dart';

class Export {
  final Lattice _lattice;

/* Constructor taking as input a lattice to be exported */
  const Export(this._lattice);

/* Outputs a lattice to stdout in a human readable format */
  void export() {
    int m = _lattice.height;
    int n = _lattice.width;
    StringBuffer buffer = StringBuffer();

    for (int i = 1; i < m - 1; i++) {
      /* print points/lines/Xs/nothing above the row of numbers */
      for (int j = 1; j < n - 1; j++) {
        buffer.write(point);
        buffer.write(" ");
        buffer.write(_formatHLine(i, j));
        buffer.write(" ");
      }
      buffer.writeln(point);

      /* print row of numbers */
      for (int j = 1; j < n - 1; j++) {
        /* print line/x/nothing to the left of number */
        buffer.write(_formatVLine(i, j));
        buffer.write(" ");
        /* print number */
        buffer.write(_formatNumber(i, j));
        buffer.write(" ");
      }
      /* print line/x/nothing to the right of last number */
      buffer.writeln(_formatVLine(i, n - 1));
    }

    /* print lines/Xs/nothing below the last row of numbers */
    for (int j = 1; j < n - 1; j++) {
      buffer.write(point);
      buffer.write(" ");
      buffer.write(_formatHLine(m - 1, j));
      buffer.write(" ");
    }
    buffer.writeln(point);
    print(buffer.toString());
  }

/* Helper function for formatting a value from the Number
 * enumeration into a human readable 0-3 or blank space. */
  String _formatNumber(int i, int j) {
    switch (_lattice.getNumber(i, j)) {
      case Number.zero:
        return "0";
      case Number.one:
        return "1";
      case Number.two:
        return "2";
      case Number.three:
        return "3";
      default:
        return blank;
    }
  }

/* Helper function for formatting a value from the Number
 * enumeration into a human readable '-', 'x' or blank space. */
  String _formatHLine(int i, int j) {
    switch (_lattice.getHLine(i, j)) {
      case Edge.line:
        return hline;
      case Edge.nLine:
        return ex;
      default:
        return blank;
    }
  }

/* Helper function for formatting a value from the Number
 * enumeration into a human readable '|', 'x' or blank space. */
  String _formatVLine(int i, int j) {
    switch (_lattice.getVLine(i, j)) {
      case Edge.line:
        return vline;
      case Edge.nLine:
        return ex;
      default:
        return blank;
    }
  }
}
