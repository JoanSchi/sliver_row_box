import 'package:example_sliver_row_box/animal_az_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final animalSuggestionProvider =
    StateNotifierProvider<AnimalSuggestionNotifier, AnimalSuggestion>((ref) {
  return AnimalSuggestionNotifier();
});

class AnimalSuggestionNotifier extends StateNotifier<AnimalSuggestion> {
  AnimalSuggestionNotifier() : super(AnimalSuggestion.from(animalsWithA));

  void invertSelected() {
    final list = state.list;
    for (AnimalSuggestionItem suggested in list) {
      suggested.inverseSelected();
    }
    state = state.copyWith(list: list);
  }

  void remove(List<String> list) {
 
    state = state.copyWith(list: state.list..removeWhere((element){
      return list.contains(element.name);
      }));
  
}

class AnimalSuggestion {
  List<AnimalSuggestionItem> list = [];

  AnimalSuggestion({
    required this.list,
  });

  AnimalSuggestion.from(List<String> names) {
    for (int i = 0; i < animalsWithA.length; i++) {
      final a = AnimalSuggestionItem(name: animalsWithA[i]);

      if (i % 6 < 3) {
        list.add(a);
      }
    }
  }

  AnimalSuggestion copyWith({
    List<AnimalSuggestionItem>? list,
  }) {
    return AnimalSuggestion(
      list: list ?? this.list,
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
