import 'package:flutter/material.dart';
import 'package:flutter_pickers/data_picker_builders.dart';

class SingleDataPicker extends StatefulWidget {
  final String? title;
  final int? selected;
  final List<String> options;

  const SingleDataPicker._({
    this.title,
    this.selected,
    required this.options,
  });

  static Future<int?> present({
    required BuildContext context,
    required List<String> options,
    String? title,
    int? selected,
  }) {
    var index = selected == null || selected < 0 || selected >= options.length
        ? options.isEmpty
            ? null
            : 0
        : selected;
    return buildModalBottomSheet(context,
        body: SingleDataPicker._(
          title: title,
          options: options.toList(),
          selected: index,
        ));
  }

  @override
  State<SingleDataPicker> createState() => _SingleDataPickerState();
}

class _SingleDataPickerState extends State<SingleDataPicker> {
  late var _selected = widget.selected;
  late final _controller =
      FixedExtentScrollController(initialItem: widget.selected ?? 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildBodyUI(
        context: context,
        child: Stack(
          children: [
            _buildIndicator(),
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildWheelView(),
            )
          ],
        ),
        result: _selected);
  }

  Widget _buildIndicator() {
    return Center(
      child: Container(
        height: cellHeight,
        decoration: const BoxDecoration(
            border: Border.symmetric(
                horizontal: BorderSide(
          width: 0.5,
          color: Color(0xFFE2E2E2),
        ))),
      ),
    );
  }

  Widget _buildWheelView() {
    return ListWheelScrollView.useDelegate(
      controller: _controller,
      physics: const FixedExtentScrollPhysics(),
      perspective: 0.00001,
      itemExtent: cellHeight,
      childDelegate: ListWheelChildBuilderDelegate(
          builder: (ctx, idx) => _buildOptionCell(idx),
          childCount: widget.options.length),
      onSelectedItemChanged: (idx) {
        setState(() {
          _selected = idx;
        });
      },
    );
  }

  Widget _buildOptionCell(int index) {
    var isHighlight = index == _selected;
    return Center(
        child: Text(
      widget.options[index],
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: isHighlight ? FontWeight.w500 : FontWeight.w400,
        color: isHighlight ? Colors.blue : null,
      ),
    ));
  }
}
