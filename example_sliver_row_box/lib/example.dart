// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example_sliver_row_box/animal_box_state.dart';
import 'package:example_sliver_row_box/animal_suggestion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sized_sliver_box.dart';
import 'package:sliver_row_box/sliver_item_row_insert_remove.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/sliver_row_item_background.dart';

class AnimalsAtoZ extends ConsumerStatefulWidget {
  const AnimalsAtoZ({super.key});

  @override
  ConsumerState<AnimalsAtoZ> createState() => _TodoRowBoxState();
}

class _TodoRowBoxState extends ConsumerState<AnimalsAtoZ> {
  final globalKey =
      const GlobalObjectKey<SliverRowBoxState>('SliverRowBox_bucketlist');

  int newAnimal = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final animalBox = ref.watch(animalBoxProvider);

    debugPrint('action ${animalBox.action}');

    return SliverRowBox<String, AnimalBoxItem>(
      ignorePointer: (bool ignore) {
        debugPrint('Ignore pointer: $ignore');
      },
      key: globalKey,
      sliverBoxAction: animalBox.consumeAction(),
      topList: [
        SliverBoxItemState(
            height: 75.0,
            key: 'top',
            value: 'Animals A-Z',
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
                color: const Color(0xFFE3C770),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                child: InkWell(
                  onTap: add,
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      'add',
                      style: TextStyle(fontSize: 18.0),
                    ),
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
        child: SizedSliverBox(
            height: state.height,
            child:
                state.editing ? EditAnimal(item: state) : animal(index, state)),
      ),
    );
  }

  Widget animal(index, state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 8.0,
        ),
        SizedBox(
            width: state.height,
            height: state.height,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: state.value.color,
                  shape: const CircleBorder(),
                  child: Checkbox(
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return Colors.black;
                        }
                        return Colors.white;
                      }),
                      checkColor: state.value.color,
                      shape: const CircleBorder(),
                      value: state.value.selected,
                      onChanged: (value) {
                        setState(() {
                          state.value.selected = value!;
                        });
                      }),
                ))),
        Expanded(
            child: Text(
          state.value.name,
          style: const TextStyle(fontSize: 18.0),
        )),
        popupMenuItem(index, state),
        const SizedBox(
          width: 8.0,
        ),
      ],
    );
  }

  void add() {
    ref.read(animalBoxProvider.notifier).insert(
        SliverBoxItemState<AnimalBoxItem>(
            key: 'newAnimal_${newAnimal++}',
            height: 60,
            editing: true,
            single: false,
            status: ItemStatusSliverBox.insert,
            value: AnimalBoxItem(name: '', color: const Color(0xFFE3C770))));
  }

  popupMenuItem(int index, SliverBoxItemState<AnimalBoxItem> state) {
    return PopupMenuButton<MenuSingleItem>(
        // Callback that sets the selected popup menu item.
        onSelected: (MenuSingleItem item) {
          switch (item) {
            case MenuSingleItem.add:
              {
                ref.read(animalBoxProvider.notifier).insert(
                    SliverBoxItemState<AnimalBoxItem>(
                        height: 60.0,
                        single: false,
                        editing: true,
                        key: 'newAnimal_${newAnimal++}',
                        value: AnimalBoxItem(
                            name: '', color: const Color(0xFFFFE1E1))),
                    index: index);

                break;
              }
            case MenuSingleItem.remove:
              {
                state.status = ItemStatusSliverBox.remove;
                ref
                    .read(animalBoxProvider.notifier)
                    .setSliverStatus(SliverBoxAction.remove);
                ref.read(animalSuggestionProvider.notifier).insert(
                    list: [state.value.name], action: SliverBoxAction.nothing);
                break;
              }
            case MenuSingleItem.edit:
              state.editing = true;
              ref.read(animalBoxProvider.notifier).update();
              break;
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuSingleItem>>[
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.add,
                child: Text('insert'),
              ),
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.remove,
                child: Text('remove'),
              ),
              const PopupMenuItem<MenuSingleItem>(
                value: MenuSingleItem.edit,
                child: Text('edit'),
              ),
            ]);
  }
}

enum MenuSingleItem {
  add,
  remove,
  edit,
}

class EditAnimal extends ConsumerStatefulWidget {
  final SliverBoxItemState<AnimalBoxItem> item;

  const EditAnimal({super.key, required this.item});

  @override
  ConsumerState<EditAnimal> createState() => _EditAnimalState();
}

class _EditAnimalState extends ConsumerState<EditAnimal> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.item.value.name);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Material(
        color: widget.item.value.color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  onSubmitted: (String? value) {
                    widget.item
                      ..editing = false
                      ..value.name = value ?? '';
                    ref.read(animalBoxProvider.notifier).update();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
