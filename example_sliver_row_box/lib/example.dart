// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:sliver_row_box/sliver_item_row_insert_remove.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/sliver_row_item_background.dart';

class TodoRowBox extends StatefulWidget {
  const TodoRowBox({super.key});

  @override
  State<TodoRowBox> createState() => _TodoRowBoxState();
}

class ToDo {
  String text;
  int id;

  ToDo({
    required this.text,
    required this.id,
  });
}

class _TodoRowBoxState extends State<TodoRowBox> {
  List<SliverBoxItemState<ToDo>> todos = [
    ToDo(text: 'Variable height', id: 0),
    ToDo(text: ';)', id: 1)
  ]
      .map((t) => SliverBoxItemState<ToDo>(
          key: '{t.id}', insertRemoveAnimation: 1.0, enabled: true, value: t))
      .toList();

  int todoId = 0;

  @override
  void initState() {
    todoId = todos.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverRowBox<String, ToDo>(
        visibleAnimated: true,
        visible: false,
        topList: [
          SliverBoxItemState(
              key: 'Todo',
              insertRemoveAnimation: 1.0,
              value: 'Todo',
              enabled: true)
        ],
        itemList: todos,
        bottomList: [
          SliverBoxItemState(
              key: 'bottom',
              insertRemoveAnimation: 1.0,
              value: 'bottom',
              enabled: true)
        ],
        buildSliverBoxItem: _buildItem,
        buildSliverBoxTopBottom: _buildTop,
        heightItem: 75);
  }

  Widget _buildTop(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<String> state}) {
    Widget w;
    if (state.key == 'Todo') {
      w = SliverRowItemBackground(
          radialTop: 36.0,
          backgroundColor: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                state.value,
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ));
    } else {
      w = SliverRowItemBackground(
          radialbottom: 36.0,
          backgroundColor: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Material(
                color: Colors.blue[600],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: InkWell(
                  onTap: add,
                  child: const Text(
                    'add',
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
            ),
          ));
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(width: 450, child: w));
  }

  Widget _buildItem(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<ToDo> state}) {
    return InsertRemoveVisibleAnimatedSliverRowItem(
        state: state,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: SizedBox(
              height: 56.0,
              width: 450,
              child: SliverRowItemBackground(
                  backgroundColor: Colors.blue[50],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 24.0,
                      ),
                      Text(
                        state.value.text,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      const Expanded(
                        child: SizedBox.expand(),
                      ),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              state.enabled = false;
                            });
                          },
                          icon: const Icon(Icons.delete))
                    ],
                  )),
            ),
          ),
        ));
  }

  void add() {
    setState(() {
      todos.add(SliverBoxItemState<ToDo>(
          key: '${todoId++}',
          value: ToDo(
            text: 'blub',
            id: todoId,
          ),
          enabled: true,
          insertRemoveAnimation: 0.0));
    });
  }
}