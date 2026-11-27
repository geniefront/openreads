import 'package:flutter/material.dart';
import 'package:openreads/core/helpers/merge_book_tags.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

class MergeBookTagsDialog extends StatefulWidget {
  const MergeBookTagsDialog({super.key});

  @override
  State<MergeBookTagsDialog> createState() => _MergeBookTagsDialogState();
}

class _MergeBookTagsDialogState extends State<MergeBookTagsDialog> {
  String? _from;
  String? _into;
  bool _saving = false;
  String? _error;

  Future<void> _merge(Set<int> ids) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final changed = await bookCubit.mergeTags(_from!, _into!, ids);
      if (mounted) Navigator.of(context).pop(changed);
    } on StateError {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'The library has changed since you opened this dialog. Please try again.';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'An error occurred while merging the tags. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Book>>(
      stream: bookCubit.allBooks,
      builder: (context, snapshot) {
        final books = snapshot.data ?? const <Book>[];
        final tags = books
            .expand((book) => bookTagNames(book.tags))
            .where((tag) => tag.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        final ids = books
            .where((book) => bookTagNames(book.tags).contains(_from))
            .map((book) => book.id)
            .whereType<int>()
            .toSet();
        final ready = !_saving &&
            tags.contains(_into) &&
            _from != _into &&
            ids.isNotEmpty;
        return PopScope(
          canPop: !_saving,
          child: AlertDialog(
            title: const Text('Merge book tags'),
            scrollable: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tags.length < 2)
                  const Text('Add two different book tags to use this action.'),
                if (tags.length >= 2) ...[
                  _tagPicker(
                    'From',
                    _from,
                    tags,
                    (value) => setState(() {
                      _from = value;
                      if (_from == _into) _into = null;
                    }),
                  ),
                  _tagPicker('Keep tag', _into,
                      tags.where((tag) => tag != _from).toList(), (value) {
                    setState(() => _into = value);
                  }),
                  if (_from != null && _into != null)
                    Text(
                        '${ids.length} book(s) will use "$_into" instead of "$_from".'),
                ],
                if (_error != null) Text(_error!),
              ],
            ),
            actions: [
              TextButton(
                onPressed: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: ready ? () => _merge(ids) : null,
                child: Text(_saving ? 'Saving...' : 'Merge tags'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tagPicker(
    String hint,
    String? value,
    List<String> tags,
    ValueChanged<String?> onChanged,
  ) =>
      DropdownButton<String>(
        isExpanded: true,
        hint: Text(hint),
        value: tags.contains(value) ? value : null,
        onChanged: _saving ? null : onChanged,
        items: [
          for (final tag in tags)
            DropdownMenuItem(
              value: tag,
              child: Text(tag, overflow: TextOverflow.ellipsis),
            ),
        ],
      );
}
