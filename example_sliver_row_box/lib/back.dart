import 'dart:async';

import 'package:example_sliver_row_box/animal_box_state.dart';
import 'package:example_sliver_row_box/animal_suggestion_state.dart';
import 'package:example_sliver_row_box/backdrop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sliver_item_row_insert_remove.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/sliver_row_item_background.dart';

const simpleColors = [
  Color(0xFFFFE15D),
  Color(0xFFF49D1A),
  Color(0xFFDC3535),
  Color(0xFFB01E68),
  Color(0xFF9EB23B),
  Color(0xFFC7D36F),
  Color(0xFFE0DECA),
  Color(0xFF22577E),
  Color(0xFF6E85B7),
  Color(0xFFB2C8DF),
  Color(0xFFC4D7E0),
  Color(0xFF9E7676),
  Color(0xFF815B5B),
  Color(0xFF594545),
  Color(0xFFE3C770),
  Color(0xFFFECD70),
  Color(0xFFFFAE6D),
  Color(0xFFF3E0B5),
];

class Back extends ConsumerStatefulWidget {
  const Back({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackState();
}

class _BackState extends ConsumerState<Back> {
  Color color = const Color(0xFFE3C770);
  @override
  Widget build(BuildContext context) {
    final a = ref.watch(animalSuggestionProvider);

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36.0),
                child: CustomScrollView(
                  slivers: [
                    SliverRowBox<String, AnimalSuggestionItem>(
                        sliverBoxAction: a.consumeAction(),
                        itemList: a.list,
                        buildSliverBoxItem: _build,
                        topList: [
                          SliverBoxItemState(
                              value: 'top', key: 'top', height: 24.0)
                        ],
                        bottomList: [
                          SliverBoxItemState(
                              value: 'bottom', key: 'bottom', height: 24.0),
                        ],
                        buildSliverBoxTopBottom: _topBottom)
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 64.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (Color color in simpleColors)
                      SizedBox(
                        width: 56.0,
                        height: 56.0,
                        child: Center(
                          child: Material(
                              clipBehavior: Clip.antiAlias,
                              color: color,
                              shape: const CircleBorder(),
                              child: InkWell(
                                child: SizedBox(
                                    width: 48.0,
                                    height: 48.0,
                                    child: this.color == color
                                        ? const Icon(Icons.check)
                                        : null),
                                onTap: () {
                                  if (this.color != color) {
                                    setState(() {
                                      this.color = color;
                                    });
                                  }
                                },
                              )),
                        ),
                      )
                  ],
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(
                    child: SizedBox(
                  height: 0.0,
                )),
                const SizedBox(
                  width: 8.0,
                ),
                TextButton(
                  onPressed: () {
                    final removed = ref
                        .read(animalSuggestionProvider.notifier)
                        .selectedToRemove();

                    ref
                        .read(animalSuggestionProvider.notifier)
                        .setSliverStatus(SliverBoxAction.remove);

                    Timer(const Duration(milliseconds: 100), () {
                      ref.read(dropBackdropProvider.notifier).state = false;
                    });

                    Timer(const Duration(milliseconds: 300), () {
                      ref.read(animalBoxProvider.notifier)
                        ..insertList(list: removed, color: color)
                        ..setSliverStatus(SliverBoxAction.insert);
                    });
                  },
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

  Widget _build(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<AnimalSuggestionItem> state}) {
    return SliverRowItemBackground(
      backgroundColor: const Color.fromARGB(255, 225, 236, 201),
      child: InsertRemoveVisibleAnimatedSliverRowItem(
          animation: animation,
          key: Key('item_${state.key}'),
          state: state,
          child: SizedBox(
              height: state.height,
              child: Row(children: [
                const SizedBox(
                  width: 8.0,
                ),
                Checkbox(
                    value: state.value.selected,
                    onChanged: (bool? value) {
                      setState(() {
                        state.value.selected = value!;
                      });
                    }),
                const SizedBox(
                  width: 8.0,
                ),
                Text(state.value.name),
              ]))),
    );
  }

  Widget _topBottom(
      {Animation? animation,
      required int index,
      required int length,
      required SliverBoxItemState<String> state}) {
    return SliverRowItemBackground(
        radialTop: state.key == 'top' ? 24.0 : 0.0,
        radialbottom: state.key == 'bottom' ? 24.0 : 0.0,
        backgroundColor: const Color.fromARGB(255, 225, 236, 201),
        child: SizedBox(
          height: state.height,
        ));
  }
}
