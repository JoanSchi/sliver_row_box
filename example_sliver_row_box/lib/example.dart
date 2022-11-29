// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:sliver_row_box/sliver_item_row_insert_remove.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/sliver_row_item_background.dart';

import 'bucket_list.dart';

class TodoRowBox extends StatefulWidget {
  const TodoRowBox({super.key});

  @override
  State<TodoRowBox> createState() => _TodoRowBoxState();
}

class ToDo {
  bool selected;
  String text;

  ToDo({
    required this.text,
    this.selected = false,
  });
}

class _TodoRowBoxState extends State<TodoRowBox> {
  final globalKey =
      const GlobalObjectKey<SliverRowBoxState>('SliverRowBox_bucketlist');
  int todoId = 0;
  late List<SliverBoxItemState<ToDo>> todos = bucketList
      .map((t) => SliverBoxItemState<ToDo>(
          height: 60.0,
          key: '${todoId++}',
          status: ItemStatusSliverBox.inserted,
          single: false,
          value: ToDo(text: t)))
      .toList();

  @override
  void initState() {
    todoId = todos.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverRowBox<String, ToDo>(
      key: globalKey,
      topList: [
        SliverBoxItemState(
            height: 75.0,
            key: 'Todo',
            value: 'Todo',
            status: ItemStatusSliverBox.inserted,
            single: false)
      ],
      itemList: todos,
      bottomList: [
        SliverBoxItemState(
            height: 75.0,
            key: 'bottom',
            value: 'bottom',
            status: ItemStatusSliverBox.inserted,
            single: false)
      ],
      buildSliverBoxItem: _buildItem,
      buildSliverBoxTopBottom: _buildTop,
    );
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
        child: Center(
            child: SizedBox(width: 450, height: state.height, child: w)));
  }

  Widget _buildItem(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<ToDo> state}) {
    return InsertRemoveVisibleAnimatedSliverRowItem(
        animation: animation,
        key: Key('item_${state.key}'),
        state: state,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Center(
            child: SizedBox(
              height: state.height,
              width: 450,
              child: SliverRowItemBackground(
                  backgroundColor: Colors.blue[50],
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 8.0,
                      ),
                      Checkbox(
                          value: state.value.selected,
                          onChanged: (value) {
                            setState(() {
                              state.value.selected = value!;
                            });
                          }),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                          child: Text(
                        state.value.text,
                        style: const TextStyle(fontSize: 18.0),
                      )),
                      IconButton(
                          onPressed: () {
                            for (var st in todos) {
                              if (st.value.selected) {
                                st.status = ItemStatusSliverBox.remove;
                              }
                            }
                            globalKey.currentState?.animateRemove();
                          },
                          icon: const Icon(Icons.more_vert)),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  )),
            ),
          ),
        ));
  }

  void add() {
    todos.add(SliverBoxItemState<ToDo>(
        height: 60.0,
        key: '${todoId++}',
        value: ToDo(
          text: 'blub',
        ),
        status: ItemStatusSliverBox.inserting,
        single: false));
    globalKey.currentState?.animateInsert();
  }
}
