import 'enums.dart';

class Coordinates {
  int i;
  int j;

  Coordinates(this.i, this.j);
}

class NumberPosition {
  Coordinates coords;
  Number num;

  NumberPosition(this.coords, this.num);
}

class EdgePosition {
  Coordinates coords;
  Edge edge;

  EdgePosition(this.coords, this.edge);
}

class PrioEdge {
  Coordinates coords;
  double priority;
  bool h;
  PrioEdge(this.coords, this.priority, this.h);
}

class AdjacencyList {
  bool u, d, l, r;

  AdjacencyList({
    required this.u,
    required this.d,
    required this.l,
    required this.r,
  });
}
