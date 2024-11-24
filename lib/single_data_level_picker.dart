import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_pickers/data_picker_builders.dart';
import 'package:flutter_pickers/level_data_source_mixin.dart';

class SingleDataLevelPicker extends StatefulWidget {
  final String? title;
  final List<LevelDataSourceMixin> items;
  final LevelDataSourceMixin? selected;
  const SingleDataLevelPicker._({
    this.title,
    this.selected,
    this.items = const [],
  });

  static Future<T?> present<T extends LevelDataSourceMixin>({
    required BuildContext context,
    String? title,
    List<T> items = const [],
    T? selected,
  }) {
    return buildModalBottomSheet(context,
        height: 350,
        body: SingleDataLevelPicker._(
          title: title,
          items: items.toList(),
          selected: selected,
        ));
  }

  @override
  State<SingleDataLevelPicker> createState() => _SingleDataLevelPickerState();
}

class _SingleDataLevelPickerState extends State<SingleDataLevelPicker>
    with TickerProviderStateMixin {
  TabController? _controller;
  late List<int?> _nodes = [null];
  late var _selected = widget.selected;

  @override
  void initState() {
    super.initState();
    if (_selected != null) {
      var flattedItems = <LevelDataSourceMixin>[];
      for (var item in widget.items) {
        flattedItems.addAll(_flatItem(item));
      }
      var index = flattedItems.indexWhere((e) => e.value == _selected!.value);
      if (index == -1 || flattedItems[index].children.isNotEmpty) {
        _selected = null;
      } else {
        _nodes = [];
        _selected = flattedItems[index];
        _initNodes(flattedItems, _selected!);
      }
    }
    _resetController();
  }

  @override
  Widget build(BuildContext context) {
    var tabs = <Tab>[];
    var pages = <Widget>[];
    _configTabView(pages: pages, tabs: tabs);
    return buildBodyUI(
      context: context,
      title: widget.title,
      hasItems: widget.items.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: TabBar(
              isScrollable: true,
              tabs: tabs,
              controller: _controller,
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              dividerColor: const Color(0xFFE2E2E2),
              dividerHeight: 0.5,
              indicatorWeight: 1,
              tabAlignment: TabAlignment.start,
              labelPadding: EdgeInsets.zero,
              indicatorPadding: const EdgeInsets.only(right: 17),
            ),
          ),
          Expanded(
              child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _controller,
            children: pages,
          ))
        ],
      ),
      result: _selected,
    );
  }

  void _configTabView({required List<Widget> pages, required List<Tab> tabs}) {
    var items = widget.items;
    for (int level = 0; level < _nodes.length; level++) {
      var node = _nodes[level];
      pages.add(_buildItemListView(items, level: level));
      if (node == null) {
        tabs.add(_buildTab(title: '请选择', right: 17));
      } else {
        var item = items[node];
        if (item.children.isNotEmpty) {
          tabs.add(_buildTab(title: '${item.title} 》'));
        } else {
          tabs.add(_buildTab(title: item.title, right: 17));
        }
        items = items[node].children;
      }
    }
  }

  Tab _buildTab({required String title, double right = 0}) {
    if (right == 0) {
      return Tab(text: title);
    }
    return Tab(
      child: Padding(
        padding: EdgeInsets.only(right: right),
        child: Text(title),
      ),
    );
  }

  Widget _buildItemListView(List<LevelDataSourceMixin> items, {int level = 0}) {
    return ListView.builder(
        itemBuilder: (ctx, idx) {
          var item = items[idx];
          if (item.children.isNotEmpty) {
            return _buildItemDirCell(item: item, node: idx, level: level);
          }
          var isSelected = item == _selected;
          return buildItemCell(
              text: item.title,
              isSelected: isSelected,
              onSelect: () {
                if (isSelected) {
                  return;
                }
                setState(() {
                  _nodes = _nodes.take(level).toList();
                  _nodes.add(idx);
                  _selected = item;
                  _resetController();
                  setState(() {});
                });
              });
        },
        itemExtent: cellHeight,
        itemCount: items.length);
  }

  Widget _buildItemDirCell({
    required LevelDataSourceMixin item,
    required int node,
    required int level,
  }) {
    Widget body = Row(
      children: [
        Expanded(
          child: Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Icon(
          Icons.keyboard_arrow_right_rounded,
          color: Color(0xFF333333),
          size: 20,
        )
      ],
    );
    body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Color(0xFFE2E2E2),
          ),
        ),
      ),
      child: body,
    );

    return GestureDetector(
      onTap: () {
        if (_nodes[level] != node) {
          _nodes[level] = node;
          _nodes = _nodes.take(level + 1).toList();
          if (item.children.isNotEmpty) {
            _nodes.add(null);
          }
          _selected = null;
          _resetController();
          setState(() {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              _controller!.animateTo(_nodes.length - 1);
            });
          });
        } else {
          _controller!.animateTo(level + 1);
        }
      },
      child: body,
    );
  }

  void _resetController() {
    _controller?.dispose();
    _controller = TabController(
      length: _nodes.length,
      initialIndex: _nodes.length - 1,
      vsync: this,
    );
  }

  List<LevelDataSourceMixin> _flatItem(LevelDataSourceMixin item) {
    var items = [item];
    for (var child in item.children) {
      items.addAll(_flatItem(child));
    }
    return items;
  }

  void _initNodes(
    List<LevelDataSourceMixin> flattedItems,
    LevelDataSourceMixin item,
  ) {
    var parentIndex = flattedItems.indexWhere(
        (e) => e.children.any((child) => child.value == item.value));
    if (parentIndex == -1) {
      _nodes.insert(
        0,
        widget.items.indexWhere((e) => e.value == item.value),
      );
      return;
    }
    var parent = flattedItems[parentIndex];
    var index = parent.children.indexWhere((e) => e.value == item.value);
    _nodes.insert(0, index);
    _initNodes(flattedItems, parent);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
