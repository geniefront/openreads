const bookTagSeparator = '||||';

List<String> bookTagNames(String? stored) => stored == null || stored.isEmpty
    ? const []
    : stored.split(bookTagSeparator);

String? mergedBookTags(String? stored, String from, String into) {
  final original = bookTagNames(stored);
  if (from == into || !original.contains(from)) return stored;

  final result = <String>[];
  var addedTarget = false;
  for (final tag in original) {
    if (tag == from || tag == into) {
      if (!addedTarget) result.add(into);
      addedTarget = true;
    } else {
      result.add(tag);
    }
  }
  return result.join(bookTagSeparator);
}