import '../shared/external/priority_queue.dart';
import '../shared/structs.dart';

int ComparePrioEdge(PrioEdge e1, PrioEdge e2) {
  return e1.priority.compareTo(e2.priority);
}

class EPQ {
  late int m_;
  late int n_;

  priority_queue<PrioEdge> pq_ = priority_queue([], ComparePrioEdge);

  void initEPQ(int m, int n) {
    assert(m > 0 && n > 0);

    m_ = m;
    n_ = n;

    for (int i = 1; i < m - 1; i++) {
      for (int j = 1; j < n - 1; j++) {
        pq_.push(createPrioEdge(0, i, j, true));
        pq_.push(createPrioEdge(0, i, j, false));
      }
      pq_.push(createPrioEdge(0, i, n - 1, false));
    }

    for (int j = 1; j < n - 1; j++) {
      pq_.push(createPrioEdge(0, m - 1, j, true));
    }
  }

  PrioEdge createPrioEdge(double prio, int i, int j, bool hLine) {
    assert(i >= 0 &&
        (i - (hLine ? 1 : 0)) < m_ &&
        j >= 0 &&
        (j - (hLine ? 0 : 1)) < n_);

    return PrioEdge(Coordinates(i, j), prio, hLine);
  }

  bool get isEmpty {
    return pq_.isEmpty;
  }

  int get size {
    return pq_.size;
  }

  PrioEdge top() {
    return pq_.top();
  }

  void push(PrioEdge pe) {
    pq_.push(pe);
  }

  void pop() {
    pq_.pop();
  }

  void emplace(double prio, int i, int j, bool hLine) {
    pq_.push(createPrioEdge(prio, i, j, hLine));
  }

  List<PrioEdge> copyPQToVector() {
    priority_queue<PrioEdge> newPQ = priority_queue([], ComparePrioEdge);
    List<PrioEdge> outputvec = List.generate(pq_.size, (i) => pq_[i]);

    return outputvec;
  }

  void copyPQ(EPQ orig) {
    List<PrioEdge> prioEdgeVec = orig.copyPQToVector();
    for (int i = 0; i < prioEdgeVec.length; i++) {
      pq_.push(prioEdgeVec[i]);
    }
  }

  void copySubsetPQ(EPQ orig) {
    PrioEdge pe = orig.top();
    List<PrioEdge> prioEdgeVec = orig.copyPQToVector();
    for (int i = 0; i < prioEdgeVec.length; i++) {
      PrioEdge cur = prioEdgeVec[i];
      if (cur.coords.i < pe.coords.i && cur.coords.j < pe.coords.j)
        pq_.push(prioEdgeVec[i]);
    }
  }
}
