import 'package:flutter_test/flutter_test.dart';
import 'package:openreads/core/helpers/merge_book_tags.dart';

void main() {
  test('replaces the source and deduplicates the target in stable order', () {
    expect(mergedBookTags('tech||||travel||||technology', 'tech', 'technology'),
        'technology||||travel');
    expect(mergedBookTags('other||||tech||||tech', 'tech', 'technology'),
        'other||||technology');
  });

  test('preserves unaffected strings, empty values and partial matches', () {
    expect(mergedBookTags('fintech', 'tech', 'technology'), 'fintech');
    expect(mergedBookTags(null, 'tech', 'technology'), isNull);
    expect(mergedBookTags('tech', 'tech', 'tech'), 'tech');
  });

  test('removes the source if the target is empty', () {
    expect(mergedBookTags('tech||||travel', 'tech', ''), '||||travel');
  });
}
