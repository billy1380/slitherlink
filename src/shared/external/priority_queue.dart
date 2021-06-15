class PriorityQueue<T> {
  final List<T> _list;
  final Comparator<T> _comparator;

  const PriorityQueue(this._list, this._comparator);

  void push(T a) {
    _list.add(a);
    _list.sort(_comparator);
  }

  bool get isEmpty {
    return _list.isEmpty;
  }

  int get size {
    return _list.length;
  }

  void pop() {
    _list.removeLast();
  }

  T operator [](int i) {
    return _list[i];
  }

  T top() {
    return _list.last;
  }
}
