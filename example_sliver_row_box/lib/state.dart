// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:example_sliver_row_box/bucket_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sliver_row_box.dart';

final animalBoxProvider =
    StateNotifierProvider<AnimalBoxNotifier, AnimalBox>((ref) {
  return AnimalBoxNotifier();
});

class AnimalBoxNotifier extends StateNotifier<AnimalBox> {
  AnimalBoxNotifier() : super(AnimalBox.from(animalsWithA));

  setSliverStatus(SliverBoxAction action) {
    state = state.copyWith(action: action);
  }
}

class AnimalBox {
  SliverBoxAction action = SliverBoxAction.nothing;
  List<Animal> notSelected = [];
  List<SliverBoxItemState<Animal>> selected = [];
  int id = 0;

  SliverBoxAction consumeAction() {
    final consumedAction = action;
    action = SliverBoxAction.nothing;
    return consumedAction;
  }

  AnimalBox({
    required this.action,
    required this.notSelected,
    required this.selected,
    required this.id,
  });

  AnimalBox.from(List<String> names) {
    final length = animalsWithA.length;

    for (int i = 0; i < animalsWithA.length; i++) {
      final a = Animal(index: i, name: animalsWithA[i]);

      if (i % 6 < 3) {
        notSelected.add(a);
      } else {
        selected
            .add(SliverBoxItemState<Animal>(key: '$i', height: 60.0, value: a));
      }
    }
    id = length;
  }

  AnimalBox copyWith({
    SliverBoxAction? action,
    List<Animal>? notSelected,
    List<SliverBoxItemState<Animal>>? selected,
    int? id,
  }) {
    return AnimalBox(
      action: action ?? this.action,
      notSelected: notSelected ?? this.notSelected,
      selected: selected ?? this.selected,
      id: id ?? this.id,
    );
  }
}

class Animal {
  bool selected;
  int index;
  String name;

  Animal({
    required this.index,
    required this.name,
    this.selected = false,
  });
}
