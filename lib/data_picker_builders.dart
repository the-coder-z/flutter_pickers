import 'package:flutter/material.dart';

const cellHeight = 50.0;

Future<T?> buildModalBottomSheet<T>(BuildContext context,
    {required Widget body, double height = 280}) {
  return showModalBottomSheet(
      context: context,
      builder: (ctx) {
        Widget bodyUI = Container(
          constraints: BoxConstraints.expand(height: height),
          child: body,
        );

        bodyUI = SafeArea(
          bottom: true,
          child: bodyUI,
        );

        bodyUI = ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Material(
            color: Colors.white,
            child: bodyUI,
          ),
        );

        bodyUI = Theme(
            data: Theme.of(context).copyWith(
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF333333),
                  ),
                ),
                splashFactory: NoSplash.splashFactory),
            child: bodyUI);
        return bodyUI;
      });
}

Widget buildBodyUI<T>(
    {required BuildContext context,
    required Widget child,
    bool hasItems = true,
    required T result,
    String? title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      buildHeader(context, title: title, confirm: () {
        Navigator.of(context).pop(result);
      }),
      Expanded(
        child: hasItems ? child : buildNoOptionView(),
      )
    ],
  );
}

Widget buildHeader(
  BuildContext context, {
  required VoidCallback confirm,
  String? title,
}) {
  var row = Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            '取消',
            style: TextStyle(color: Color(0xFF999999)),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop(null);
        },
      ),
      if (title?.isNotEmpty == true)
        Text(
          title!,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      InkWell(
        onTap: confirm,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            '确定',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      )
    ],
  );
  return Container(
    decoration: const BoxDecoration(
        border: Border(
      bottom: BorderSide(color: Color(0xFFE2E2E2), width: 0.5),
    )),
    child: row,
  );
}

Widget buildNoOptionView() => const Center(
      child: Text(
        '无选项',
        style: TextStyle(color: Color(0xFF999999)),
      ),
    );

Widget buildItemCell({
  required String text,
  required VoidCallback onSelect,
  bool isSelected = false,
}) {
  Widget body = Row(
    children: [
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isSelected ? Colors.blue : null,
          ),
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Icon(
        Icons.radio_button_on_outlined,
        size: 20,
        color: isSelected ? Colors.blue : Colors.transparent,
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
    onTap: onSelect,
    child: body,
  );
}
