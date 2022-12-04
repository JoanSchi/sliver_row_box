import 'package:example_sliver_row_box/animal_box_state.dart';
import 'package:example_sliver_row_box/animal_suggestion_state.dart';
import 'package:example_sliver_row_box/backdrop_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_row_box/sliver_row_box.dart';

class BackDropAppbar extends ConsumerStatefulWidget {
  const BackDropAppbar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _State();
}

class _State extends ConsumerState<BackDropAppbar> {
  @override
  Widget build(BuildContext context) {
    bool down = ref.watch(dropBackdropProvider);

    return Stack(
      children: [
        Center(
          child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 200,
              ),
              child: down
                  ? const Text(
                      key: Key('insert'),
                      'Insert',
                      style: TextStyle(
                        fontSize: 24.0,
                      ))
                  : const Text(
                      key: Key('rsb'),
                      'RowSliverBox',
                      style: TextStyle(
                        fontSize: 24.0,
                      ),
                    )),
        ),
        Positioned(
          left: 8.0,
          top: 8.0,
          bottom: 8.0,
          child: IconButton(
              onPressed: () {
                final drop = ref.read(dropBackdropProvider.notifier).state;
                if (drop) {
                  ref.read(animalSuggestionProvider.notifier).invertSelected();
                } else {
                  ref.read(animalBoxProvider.notifier).invertSelected();
                }
              },
              icon: const Icon(
                Icons.published_with_changes,
              )),
        ),
        Positioned(
          right: 8.0,
          top: 8.0,
          bottom: 8.0,
          child: down
              ? IconButton(
                  onPressed: () {
                    ref.read(dropBackdropProvider.notifier).state = false;
                  },
                  icon: const Icon(
                    Icons.close,
                  ))
              : Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          ref.read(dropBackdropProvider.notifier).state = true;
                        },
                        icon: const Icon(
                          Icons.add,
                        )),
                    IconButton(
                        onPressed: () {
                          List<String> removed = ref
                              .read(animalBoxProvider.notifier)
                              .selectedToRemove();

                          ref
                              .read(animalBoxProvider.notifier)
                              .setSliverStatus(SliverBoxAction.remove);

                          ref.read(animalSuggestionProvider.notifier).insert(
                              list: removed, action: SliverBoxAction.nothing);
                        },
                        icon: const Icon(
                          Icons.delete,
                        ))
                  ],
                ),
        ),
      ],
    );
  }
}
