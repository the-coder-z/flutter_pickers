import 'package:flutter/material.dart';
import 'package:flutter_pickers/data_picker_builders.dart';

class MultiDataPicker extends StatefulWidget {
  final String? title;
  final List<String> options;
  final List<int> selected;
  const MultiDataPicker._(
      {this.title, this.options = const [], this.selected = const []});

  static Future<List<int>?> present({
    required BuildContext context,
    String? title,
    List<String> options = const [],
    List<int>? selected,
  }) {
    var indices = selected?.toList() ?? [];
    indices.removeWhere((index) => index < 0 && index >= options.length);
    return buildModalBottomSheet(context,
        height: 350,
        body: MultiDataPicker._(
          title: title,
          options: options,
          selected: indices,
        ));
  }

  @override
  State<MultiDataPicker> createState() => _MultiDataPickerState();
}

class _MultiDataPickerState extends State<MultiDataPicker> {
  late final _result = widget.selected;

  @override
  Widget build(BuildContext context) {
    return buildBodyUI(
      context: context,
      title: widget.title,
      child: _buildOptionListView(),
      result: _result,
    );
  }

  Widget _buildOptionListView() {
    return ListView.builder(
        itemBuilder: (ctx, idx) {
          var isSelected = _result.contains(idx);
          return buildItemCell(
              text: widget.options[idx],
              isSelected: isSelected,
              onSelect: () {
                setState(() {
                  if (isSelected) {
                    _result.remove(idx);
                  } else {
                    _result.add(idx);
                  }
                  _result.sort((left, right) => left.compareTo(right));
                });
              });
        },
        itemExtent: cellHeight,
        itemCount: widget.options.length);
  }
}
