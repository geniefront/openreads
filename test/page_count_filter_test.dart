import 'package:flutter_test/flutter_test.dart';
import 'package:openreads/core/helpers/page_count_filter.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_state.dart';

void main() {
  test('includes the 200-page boundary but excludes unknown page counts', () {
    expect([null, 0, 1, 200, 201].where((n) => matchesPageLimit(n, true)), [1, 200]);
    expect(matchesPageLimit(null, false), isTrue);
  });

  test('older sort state loads with the filter off and new state round-trips,', () {
    final old = {
      'sort_type': 0,
      'sort_order': true,
      'only_favourite': false,
      'filter_tags_as_and': false,
      'filter_out_tags': false,
      'onlyFavourite': false,
      'short_books_only': false,
      'ignore_articles': false
    };
    final state = SortState.fromJson(old);
    expect(state.shortBooksOnly, isFalse);
    final enable = state.copyWith(shortBooksOnly: true);
    expect(enable, isNot(state));
    expect(SortState.fromJson(enable.toJson()!), enable);
  });
}