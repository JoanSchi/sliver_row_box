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

  selectedToRemove() {
    for (var t in state.list) {
      if (t.value.selected) {
        t.status = ItemStatusSliverBox.remove;
      }
    }
  }

  insert(List<String> list) {
    state.copyWith(action: SliverBoxAction.insert, list: state);
  }

  setSliverStatus(SliverBoxAction action) {
    state = state.copyWith(action: action);
  }
}

class AnimalBox {
  SliverBoxAction action = SliverBoxAction.nothing;
  List<SliverBoxItemState<AnimalBoxItem>> list = [];
  int id = 0;

  SliverBoxAction consumeAction() {
    final consumedAction = action;
    action = SliverBoxAction.nothing;
    return consumedAction;
  }

  void insert(List<String> list) {
    this.list.addAll([
      for (String name in list)
        SliverBoxItemState<AnimalBoxItem>(
            key: '${id++}', height: 60.0, value: AnimalBoxItem(name: name))
    ]);
  }

  AnimalBox({
    required this.action,
    required this.list,
    required this.id,
  });

  AnimalBox.from(List<String> names) {
    final length = animalsWithA.length;

    for (int i = 0; i < length; i++) {
      final a = AnimalBoxItem(name: animalsWithA[i]);

      if (!(i % 6 < 3)) {
        list.add(SliverBoxItemState<AnimalBoxItem>(
            key: '$i', height: 60.0, value: a));
      }
    }
    id = length;
  }

  AnimalBox copyWith({
    SliverBoxAction? action,
    List<AnimalBoxItem>? notSelected,
    List<SliverBoxItemState<AnimalBoxItem>>? list,
    int? id,
  }) {
    return AnimalBox(
      action: action ?? this.action,
      list: list ?? this.list,
      id: id ?? this.id,
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
}
