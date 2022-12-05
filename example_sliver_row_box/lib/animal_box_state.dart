// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:example_sliver_row_box/animal_az_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sliver_row_box.dart';

final animalBoxProvider =
    StateNotifierProvider<AnimalBoxNotifier, AnimalBox>((ref) {
  return AnimalBoxNotifier();
});

class AnimalBoxNotifier extends StateNotifier<AnimalBox> {
  AnimalBoxNotifier() : super(AnimalBox.from(animalsWithA));

  List<String> selectedToRemove() {
    List<String> removed = [];

    for (var t in state.list) {
      if (t.value.selected) {
        t.status = ItemStatusSliverBox.remove;
        removed.add(t.value.name);
      }
    }
    return removed;
  }

  void insertList(
      {required List<String> list,
      Color color = const Color(0xFF80ba27),
      SliverBoxAction action = SliverBoxAction.insert}) {
    state.list.addAll([
      for (String name in list)
        SliverBoxItemState<AnimalBoxItem>(
            key: '${name}_$color',
            height: 60.0,
            status: action == SliverBoxAction.insert
                ? ItemStatusSliverBox.insert
                : ItemStatusSliverBox.completed,
            value: AnimalBoxItem(name: name, color: color))
    ]);

    state.list.sort((a, b) {
      int c = a.value.name.toLowerCase().compareTo(b.value.name.toLowerCase());

      if (c != 0) {
        return c;
      }
      return (a.value.color?.value ?? 0) - (b.value.color?.value ?? 0);
    });

    state = state.copyWith(action: action);
  }

  void invertSelected() {
    for (SliverBoxItemState<AnimalBoxItem> state in state.list) {
      state.value.inverseSelected();
    }
    state = state.copyWith();
  }

  setSliverStatus(SliverBoxAction action) {
    state = state.copyWith(action: action);
  }

  insert(SliverBoxItemState<AnimalBoxItem> item, {int index = -1}) {
    state = state.copyWith(
        list: state.list..insert(index == -1 ? state.list.length : index, item),
        action: SliverBoxAction.insert);
  }

  void update() {
    state = state.copyWith();
  }
}

class AnimalBox {
  SliverBoxAction action = SliverBoxAction.nothing;
  List<SliverBoxItemState<AnimalBoxItem>> list = [];

  SliverBoxAction consumeAction() {
    final consumedAction = action;
    action = SliverBoxAction.nothing;
    return consumedAction;
  }

  AnimalBox({
    required this.action,
    required this.list,
  });

  AnimalBox.from(List<String> names) {
    final length = animalsWithA.length;

    for (int i = 0; i < length; i++) {
      if (i % 6 < 2) {
        final a = AnimalBoxItem(
            name: animalsWithA[i], color: const Color(0xFFE3C770));

        list.add(SliverBoxItemState<AnimalBoxItem>(
            key: a.key, height: 60.0, value: a));
      }
    }
  }

  AnimalBox copyWith({
    SliverBoxAction? action,
    List<SliverBoxItemState<AnimalBoxItem>>? list,
  }) {
    return AnimalBox(
      action: action ?? this.action,
      list: list ?? this.list,
    );
  }
}

class AnimalBoxItem {
  bool selected;
  Color? color;
  String name;

  AnimalBoxItem({
    this.color,
    required this.name,
    this.selected = false,
  });

  void inverseSelected() => selected = !selected;

  String get key => '${name}_$color';
}
