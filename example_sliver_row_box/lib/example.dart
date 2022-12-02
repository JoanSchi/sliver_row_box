// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example_sliver_row_box/animal_box_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sliver_item_row_insert_remove.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/sliver_row_item_background.dart';

class TodoRowBox extends ConsumerStatefulWidget {
  const TodoRowBox({super.key});

  @override
  ConsumerState<TodoRowBox> createState() => _TodoRowBoxState();
}

class _TodoRowBoxState extends ConsumerState<TodoRowBox> {
  final globalKey =
      const GlobalObjectKey<SliverRowBoxState>('SliverRowBox_bucketlist');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final animalBox = ref.watch(animalBoxProvider);

    debugPrint('action ${animalBox.action}');

    return SliverRowBox<String, AnimalBoxItem>(
      key: globalKey,
      sliverBoxAction: animalBox.consumeAction(),
      topList: [
        SliverBoxItemState(
            height: 75.0,
            key: 'top',
            value: 'top',
            status: ItemStatusSliverBox.completed,
            single: false)
      ],
      itemList: animalBox.list,
      bottomList: [
        SliverBoxItemState(
            height: 75.0,
            key: 'bottom',
            value: 'bottom',
            status: ItemStatusSliverBox.completed,
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
    if (state.key == 'top') {
      w = SliverRowItemBackground(
          radialTop: 36.0,
          backgroundColor: const Color(0xFFFFF8EA),
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
          backgroundColor: const Color(0xFFFFF8EA),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Material(
                color: Colors.brown[600],
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

    return w;
  }

  Widget _buildItem(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<AnimalBoxItem> state}) {
    return SliverRowItemBackground(
      backgroundColor: const Color(0xFFFFF8EA),
      child: InsertRemoveVisibleAnimatedSliverRowItem(
        animation: animation,
        key: Key('item_${state.key}'),
        state: state,
        child: SizedBox(
            height: state.height,
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
                  state.value.name,
                  style: const TextStyle(fontSize: 18.0),
                )),
                popupMenuItem(state),
                // IconButton(
                //     onPressed: () {
                //       for (var st in todos) {
                //         if (st.value.selected) {
                //           st.status = ItemStatusSliverBox.remove;
                //         }
                //       }
                //       globalKey.currentState?.animateRemove();
                //     },
                //     icon: const Icon(Icons.more_vert)),
                const SizedBox(
                  width: 8.0,
                ),
              ],
            )),
      ),
    );
  }

  void add() {
    // todos.add(SliverBoxItemState<ToDo>(
    //     height: 60.0,
    //     key: '${todoId++}',
    //     value: ToDo(
    //       name: 'blub',
    //     ),
    //     status: ItemStatusSliverBox.insert,
    //     single: false));
    // globalKey.currentState?.animateInsert();
  }

  popupMenuItem(SliverBoxItemState<AnimalBoxItem> state) {
    return PopupMenuButton<MenuSingleItem>(
        // Callback that sets the selected popup menu item.
        onSelected: (MenuSingleItem item) {
          switch (item) {
            case MenuSingleItem.add:
              {
                // int index = todos.indexOf(state);
                // todos.insert(
                //     index,
                //     SliverBoxItemState<ToDo>(
                //         single: false,
                //         key: '${todoId++}',
                //         status: ItemStatusSliverBox.insert,
                //         height: 60.0,
                //         value: ToDo(name: 'hiep')));
                // globalKey.currentState?.animateInsert();
                break;
              }
            case MenuSingleItem.remove:
              {
                state.status = ItemStatusSliverBox.remove;
                globalKey.currentState?.animateRemove();
                break;
              }
            case MenuSingleItem.removeSelected:
              {
                final animalBox = ref.read(animalBoxProvider);
                for (SliverBoxItemState<AnimalBoxItem> a in animalBox.list) {
                  if (a.value.selected) {
                    a.status = ItemStatusSliverBox.remove;
                  }
                }
                ref
                    .read(animalBoxProvider.notifier)
                    .setSliverStatus(SliverBoxAction.remove);
                // globalKey.currentState?.animateRemove();
              }
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuSingleItem>>[
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.add,
                child: Text('add'),
              ),
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.remove,
                child: Text('remove'),
              ),
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.removeSelected,
                child: Text('remove selected'),
              ),
            ]);
  }
}

enum MenuSingleItem {
  add,
  remove,
  removeSelected,
}
