// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example_sliver_row_box/animal_az_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sliver_row_box/sliver_row_box.dart';

final animalSuggestionProvider =
    StateNotifierProvider<AnimalSuggestionNotifier, AnimalSuggestion>((ref) {
  return AnimalSuggestionNotifier();
});

class AnimalSuggestionNotifier extends StateNotifier<AnimalSuggestion> {
  AnimalSuggestionNotifier() : super(AnimalSuggestion.from(animalsWithA));

  void invertSelected() {
    final list = state.list;
    for (SliverBoxItemState<AnimalSuggestionItem> suggested in list) {
      suggested.value.inverseSelected();
    }
    state = state.copyWith(list: list);
  }

  void insert({required List<String> list, required SliverBoxAction action}) {
    state.list.addAll([
      for (String name in list)
        SliverBoxItemState<AnimalSuggestionItem>(
            key: name,
            height: 60.0,
            status: action == SliverBoxAction.insert
                ? ItemStatusSliverBox.insert
                : ItemStatusSliverBox.completed,
            value: AnimalSuggestionItem(name: name))
    ]);

    state.list.sort((a, b) {
      return a.value.name.toLowerCase().compareTo(b.value.name.toLowerCase());
    });

    int i = 0;
    int l = state.list.length < 8 ? state.list.length : 8;

    while (i < l) {
      debugPrint('index $i ${state.list[i].value.name}');
      i++;
    }

    state = state.copyWith(action: action);
  }

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

  setSliverStatus(SliverBoxAction action) {
    state = state.copyWith(action: action);
  }

  update() {
    state = state.copyWith();
  }
}

class AnimalSuggestion {
  List<SliverBoxItemState<AnimalSuggestionItem>> list = [];
  SliverBoxAction action = SliverBoxAction.nothing;

  SliverBoxAction consumeAction() {
    final consumedAction = action;
    action = SliverBoxAction.nothing;
    return consumedAction;
  }

  AnimalSuggestion({
    required this.list,
    this.action = SliverBoxAction.nothing,
  });

  AnimalSuggestion.from(List<String> names) {
    for (int i = 0; i < animalsWithA.length; i++) {
      if (i % 6 < 3) {
        final a = AnimalSuggestionItem(name: animalsWithA[i]);
        list.add(SliverBoxItemState<AnimalSuggestionItem>(
            key: a.name,
            height: 60.0,
            status: ItemStatusSliverBox.completed,
            value: a));
      }
    }
  }

  AnimalSuggestion copyWith({
    List<SliverBoxItemState<AnimalSuggestionItem>>? list,
    SliverBoxAction? action,
  }) {
    return AnimalSuggestion(
      list: list ?? this.list,
      action: action ?? this.action,
    );
  }
}

class AnimalSuggestionItem {
  bool selected;
  String name;

  void inverseSelected() => selected = !selected;

  AnimalSuggestionItem({
    required this.name,
    this.selected = false,
  });
}
