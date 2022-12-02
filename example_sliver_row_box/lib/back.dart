import 'package:example_sliver_row_box/animal_box_state.dart';
import 'package:example_sliver_row_box/animal_suggestion_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Back extends ConsumerStatefulWidget {
  const Back({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackState();
}

class _BackState extends ConsumerState<Back> {
  @override
  Widget build(BuildContext context) {
    final a = ref.watch(animalSuggestionProvider);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: ((context, index) {
                  final item = a.list[index];
                  return SizedBox(
                    height: 56.0,
                    child: Row(children: [
                      Checkbox(
                          value: item.selected,
                          onChanged: (bool? value) {
                            setState(() {
                              item.selected = value!;
                            });
                          }),
                      Text(item.name),
                    ]),
                  );
                }),
                itemCount: a.list.length,
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            Row(
              children: [
                const Expanded(
                    child: SizedBox(
                  height: 0.0,
                )),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(animalSuggestionProvider.notifier)
                        .invertSelected();
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('Invert'),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(animalSuggestionProvider.notifier)
                        .invertSelected();
                  },
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                  child: const Text('Sort'),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(animalSuggestionProvider.notifier)
                        .invertSelected();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[100],
                      shape: const StadiumBorder()),
                  child: const Text('Insert'),
                )
              ],
            ),
            const SizedBox(
              height: 16.0,
            ),
          ],
        ));
  }
}
