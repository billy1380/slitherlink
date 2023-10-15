import 'dart:io';

import 'package:logging/logging.dart';

import 'enums.dart';
import 'grid.dart';

const String point = ".";
const String hline = "-";
const String vline = "|";
const String ex = "x";
const String blank = " ";

class Import {
  static final Logger logger = Logger("Import");

  final Grid _lattice;

  Import(this._lattice);

/* Reads from stdin and initializes a lattice based on given
 * dimensions and three separate grids, one each for numbers,
 * horizontal lines, and vertical lines. */
  void buildLattice(String filename) {
    File slkfile = File(filename);

    if (slkfile.existsSync()) {
      List<String> contents = slkfile.readAsLinesSync();

      contents = _removeCommentsAndEmptyLines(contents);

      int lineIndex = 0;

      /* get dimensions */
      int m, n;
      String dimsLine = contents[lineIndex];
      List<String> splitDims = dimsLine.split(" ");

      assert(splitDims.length == 2,
          "There should only be 2 dimentions delimited by a space");

      m = int.parse(splitDims.first);
      n = int.parse(splitDims.last);

      _lattice.initArrays(m + 2, n + 2);
      _lattice.initUpdateMatrix();

      /* numbers */
      for (int i = 0; i < m; i++) {
        lineIndex++;
        _importNumberRow(i + 1, contents[lineIndex]);
      }

      /* horizontal lines */
      for (int i = 0; i < m + 1; i++) {
        lineIndex++;
        _importHLineRow(i + 1, contents[lineIndex]);
      }
      for (int j = 0; j < n + 2; j++) {
        _lattice.setHLine(0, j, Edge.nLine);
        _lattice.setHLine(m + 2, j, Edge.nLine);
      }

      /* vertical lines */
      for (int j = 0; j < n + 3; j++) {
        _lattice.setVLine(0, j, Edge.nLine);
        _lattice.setVLine(m + 1, j, Edge.nLine);
      }
      for (int i = 0; i < m + 2; i++) {
        _lattice.setVLine(i, 0, Edge.nLine);
        _lattice.setVLine(i, n + 2, Edge.nLine);
      }

      for (int i = 0; i < m; i++) {
        lineIndex++;
        _importVLineRow(i + 1, contents[lineIndex]);
      }
    } else {
      logger.severe("Unable to open file");
    }
  }

  List<String> _removeCommentsAndEmptyLines(List<String> lines) {
    List<String> cleanedLines = <String>[];

    for (String line in lines) {
      if (line.isEmpty) {
        // remove empty line
      } else {
        List<String> commentSplit = line.split("#");

        if (commentSplit.first.trim().isEmpty) {
          // remove empty line
        } else {
          cleanedLines.add(commentSplit.first.trim());
        }
      }
    }

    return cleanedLines;
  }

/* Initializes an empty lattice based on given dimensions */
  void buildEmptyLattice(int m, int n) {
    _lattice.initArrays(m + 2, n + 2);
    _lattice.initUpdateMatrix();

    for (int i = 0; i < m + 1; i++) {
      _lattice.setHLine(i + 1, 0, Edge.nLine);
    }

    for (int i = 0; i < m + 2; i++) {
      _lattice.setVLine(i, 0, Edge.nLine);
      _lattice.setVLine(i, n + 2, Edge.nLine);
    }

    for (int j = 0; j < n + 3; j++) {
      _lattice.setVLine(0, j, Edge.nLine);
      _lattice.setVLine(m + 1, j, Edge.nLine);
    }

    for (int j = 0; j < n + 2; j++) {
      _lattice.setHLine(0, j, Edge.nLine);
      _lattice.setHLine(m + 2, j, Edge.nLine);
    }

    for (int j = 0; j < m + 3; j++) {
      _lattice.setHLine(j, 0, Edge.nLine);
      _lattice.setHLine(j, n + 1, Edge.nLine);
    }
  }

/* Helper function for reading a line from stdin and
 * interpreting 0-3 as their corresponding values in
 * the Number enumeration. */
  void _importNumberRow(int i, String row) {
    for (int j = 0; j < row.length; j++) {
      String c = row[j];
      switch (c) {
        case "0":
          _lattice.setNumber(i, j + 1, Number.zero);
          break;
        case "1":
          _lattice.setNumber(i, j + 1, Number.one);
          break;
        case "2":
          _lattice.setNumber(i, j + 1, Number.two);
          break;
        case "3":
          _lattice.setNumber(i, j + 1, Number.three);
          break;
        default:
          _lattice.setNumber(i, j + 1, Number.none);
          break;
      }
    }
  }

/* Helper function for reading a line from stdin and
 * interpreting '-' and 'x' as their corresponding values in
 * the Number enumeration. */
  void _importHLineRow(int i, String row) {
    _lattice.setHLine(i, 0, Edge.nLine);
    for (int j = 0; j < row.length; j++) {
      String c = row[j];
      switch (c) {
        case "-":
          _lattice.setHLine(i, j + 1, Edge.line);
          break;
        case "x":
          _lattice.setHLine(i, j + 1, Edge.nLine);
          break;
        default:
          _lattice.setHLine(i, j + 1, Edge.empty);
          break;
      }
    }
    _lattice.setHLine(i, row.length + 1, Edge.nLine);
  }

/* Helper function for reading a line from stdin and
 * interpreting '-' and 'x' as their corresponding values in
 * the Number enumeration. */
  void _importVLineRow(int i, String row) {
    for (int j = 0; j < row.length; j++) {
      String c = row[j];
      switch (c) {
        case "-":
          _lattice.setVLine(i, j + 1, Edge.line);
          break;
        case "x":
          _lattice.setVLine(i, j + 1, Edge.nLine);
          break;
        default:
          _lattice.setVLine(i, j + 1, Edge.empty);
          break;
      }
    }
  }
}
