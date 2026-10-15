import 'dart:async';

class GetMicrotask {
  int _version = 0;
  int _microtask = 0;

  int get microtask => _microtask;
  int get version => _version;

  void exec(Function callback) {
    if (_microtask == _version) {
      _microtask++;
      scheduleMicrotask(() {
        _version++;
        _microtask = _version;
        callback();
      });
    }
  }
}

class GetQueue {
  final List<_Item> _queue = [];
  bool _active = false;

  Future<T> add<T>(Function job) {
    var completer = Completer<T>();
    _queue.add(_Item(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    _queue.clear();
  }

  void _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      var item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } catch (e, s) {
        // 这里必须 catch 全部类型：只接 Exception 会漏掉 Error（AssertionError、
        // 空值断言等）和裸字符串 throw。
        item.completer.completeError(e, s);
      } finally {
        // 复位也必须放在 finally：一旦异常越过 catch，_active 会永远停在 true，
        // 队列再也不排空，之后每个 add() 返回的 future 全部悬着不完成。
        _active = false;
        _check();
      }
    }
  }
}

class _Item {
  final dynamic completer;
  final dynamic job;

  _Item(this.completer, this.job);
}
