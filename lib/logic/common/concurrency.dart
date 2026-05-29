/// Runs [task] over [items] with at most [concurrency] futures in flight at
/// once, returning a map of each item to its result.
///
/// Unlike `Future.wait(items.map(task))` — which starts *every* task eagerly —
/// this caps the number of simultaneous operations. Used for marker-photo
/// decoding on the trip map, where firing one decode per stop at once can
/// spike memory/network on a long itinerary. Results preserve no ordering
/// guarantee beyond the returned map; items are pulled in iteration order by
/// a fixed pool of workers.
///
/// [concurrency] is clamped to at least 1. If [items] is empty the result is
/// an empty map and no workers start.
Future<Map<T, R>> mapBounded<T, R>(
  Iterable<T> items,
  Future<R> Function(T item) task, {
  int concurrency = 5,
}) async {
  final list = items.toList(growable: false);
  final results = <T, R>{};
  if (list.isEmpty) return results;

  final limit = concurrency < 1 ? 1 : concurrency;
  var next = 0;

  Future<void> worker() async {
    while (true) {
      final i = next++;
      if (i >= list.length) break;
      final item = list[i];
      results[item] = await task(item);
    }
  }

  final poolSize = limit < list.length ? limit : list.length;
  await Future.wait([for (var w = 0; w < poolSize; w++) worker()]);
  return results;
}
