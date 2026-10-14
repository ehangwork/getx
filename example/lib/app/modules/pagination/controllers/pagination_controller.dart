import 'package:get/get.dart';

/// ScrollMixin 自带一个 ScrollController，滚到顶或底时回调一次，
/// 并且自带「同一方向只发一次请求」的守卫，不需要自己置 loading 标志。
class PaginationController extends GetxController with ScrollMixin {
  final items = <String>[].obs;
  final isLoading = false.obs;

  int _page = 0;

  @override
  void onInit() {
    super.onInit();
    _loadMore();
  }

  @override
  Future<void> onEndScroll() => _loadMore();

  @override
  Future<void> onTopScroll() async {
    if (_page == 0) return;
    _page = 0;
    items.clear();
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (isLoading.value) return;
    isLoading.value = true;
    // 换成真实的分页请求即可
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _page++;
    items.addAll(List.generate(20, (i) => '第 $_page 页 · 第 ${i + 1} 条'));
    isLoading.value = false;
  }

  Future<void> refresh() async {
    _page = 0;
    items.clear();
    await _loadMore();
  }
}
