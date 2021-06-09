class priority_queue<T> {
  List<T> _list;
  Comparator<T> _comparator;
  priority_queue(this._list, this._comparator);

  void push(T a) {
    _list.add(a);
    _list.sort(_comparator);
  }

  bool empty() {
    return _list.isEmpty;
  }

  int size() {
    return _list.length;
  }

  void pop() {
    _list.removeLast();
  }

  T operator [](int i) {
    return _list[i];
  }

  T top() {
    return _list.first;
  }
}
