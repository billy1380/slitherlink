import '../shared/structs.dart';
import 'package:collection/collection.dart';

int comparePrioEdge(PrioEdge e1, PrioEdge e2) =>
    e1.priority.compareTo(e2.priority);

class EPQ {
  late int _m;
  late int _n;

  PriorityQueue<PrioEdge> pq_ = PriorityQueue<PrioEdge>(comparePrioEdge);

  void initEPQ(int m, int n) {
    assert(m > 0 && n > 0);

    _m = m;
    _n = n;

    for (int i = 1; i < m - 1; i++) {
      for (int j = 1; j < n - 1; j++) {
        pq_.add(createPrioEdge(0, i, j, true));
        pq_.add(createPrioEdge(0, i, j, false));
      }
      pq_.add(createPrioEdge(0, i, n - 1, false));
    }

    for (int j = 1; j < n - 1; j++) {
      pq_.add(createPrioEdge(0, m - 1, j, true));
    }
  }

  PrioEdge createPrioEdge(double prio, int i, int j, bool hLine) {
    assert(i >= 0 &&
        (i - (hLine ? 1 : 0)) < _m &&
        j >= 0 &&
        (j - (hLine ? 0 : 1)) < _n);

    return PrioEdge(Coordinates(i, j), prio, hLine);
  }

  bool get isEmpty {
    return pq_.isEmpty;
  }

  int get size {
    return pq_.length;
  }

  PrioEdge top() {
    return pq_.first;
  }

  void push(PrioEdge pe) {
    pq_.add(pe);
  }

  void pop() {
    pq_.removeFirst();
  }

  void emplace(double prio, int i, int j, bool hLine) {
    pq_.add(createPrioEdge(prio, i, j, hLine));
  }

  List<PrioEdge> copyPQToVector() {
    List<PrioEdge> outputvec = pq_.toList();

    return outputvec;
  }

  void copyPQ(EPQ orig) {
    List<PrioEdge> prioEdgeVec = orig.copyPQToVector();
    for (int i = 0; i < prioEdgeVec.length; i++) {
      pq_.add(prioEdgeVec[i]);
    }
  }

  void copySubsetPQ(EPQ orig) {
    PrioEdge pe = orig.top();
    List<PrioEdge> prioEdgeVec = orig.copyPQToVector();
    for (int i = 0; i < prioEdgeVec.length; i++) {
      PrioEdge cur = prioEdgeVec[i];

      if (cur.coords.i < pe.coords.i && cur.coords.j < pe.coords.j) {
        pq_.add(prioEdgeVec[i]);
      }
    }
  }
}
