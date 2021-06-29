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

  final Grid lattice_;
  late int m_; /* number of rows */
  late int n_; /* number of columns */

  Import(this.lattice_);

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

      lattice_.initArrays(m + 2, n + 2);
      lattice_.initUpdateMatrix();

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
        lattice_.setHLine(0, j, Edge.NLINE);
        lattice_.setHLine(m + 2, j, Edge.NLINE);
      }

      /* vertical lines */
      for (int j = 0; j < n + 3; j++) {
        lattice_.setVLine(0, j, Edge.NLINE);
        lattice_.setVLine(m + 1, j, Edge.NLINE);
      }
      for (int i = 0; i < m + 2; i++) {
        lattice_.setVLine(i, 0, Edge.NLINE);
        lattice_.setVLine(i, n + 2, Edge.NLINE);
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
    lattice_.initArrays(m + 2, n + 2);
    lattice_.initUpdateMatrix();

    for (int i = 0; i < m + 1; i++) {
      lattice_.setHLine(i + 1, 0, Edge.NLINE);
    }

    for (int i = 0; i < m + 2; i++) {
      lattice_.setVLine(i, 0, Edge.NLINE);
      lattice_.setVLine(i, n + 2, Edge.NLINE);
    }

    for (int j = 0; j < n + 3; j++) {
      lattice_.setVLine(0, j, Edge.NLINE);
      lattice_.setVLine(m + 1, j, Edge.NLINE);
    }

    for (int j = 0; j < n + 2; j++) {
      lattice_.setHLine(0, j, Edge.NLINE);
      lattice_.setHLine(m + 2, j, Edge.NLINE);
    }

    for (int j = 0; j < m + 3; j++) {
      lattice_.setHLine(j, 0, Edge.NLINE);
      lattice_.setHLine(j, n + 1, Edge.NLINE);
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
          lattice_.setNumber(i, j + 1, Number.ZERO);
          break;
        case "1":
          lattice_.setNumber(i, j + 1, Number.ONE);
          break;
        case "2":
          lattice_.setNumber(i, j + 1, Number.TWO);
          break;
        case "3":
          lattice_.setNumber(i, j + 1, Number.THREE);
          break;
        default:
          lattice_.setNumber(i, j + 1, Number.NONE);
          break;
      }
    }
  }

/* Helper function for reading a line from stdin and
 * interpreting '-' and 'x' as their corresponding values in
 * the Number enumeration. */
  void _importHLineRow(int i, String row) {
    lattice_.setHLine(i, 0, Edge.NLINE);
    for (int j = 0; j < row.length; j++) {
      String c = row[j];
      switch (c) {
        case "-":
          lattice_.setHLine(i, j + 1, Edge.LINE);
          break;
        case "x":
          lattice_.setHLine(i, j + 1, Edge.NLINE);
          break;
        default:
          lattice_.setHLine(i, j + 1, Edge.EMPTY);
          break;
      }
    }
    lattice_.setHLine(i, row.length + 1, Edge.NLINE);
  }

/* Helper function for reading a line from stdin and
 * interpreting '-' and 'x' as their corresponding values in
 * the Number enumeration. */
  void _importVLineRow(int i, String row) {
    for (int j = 0; j < row.length; j++) {
      String c = row[j];
      switch (c) {
        case "-":
          lattice_.setVLine(i, j + 1, Edge.LINE);
          break;
        case "x":
          lattice_.setVLine(i, j + 1, Edge.NLINE);
          break;
        default:
          lattice_.setVLine(i, j + 1, Edge.EMPTY);
          break;
      }
    }
  }
}
