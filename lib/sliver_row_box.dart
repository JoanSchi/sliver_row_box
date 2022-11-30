// ignore_for_file: public_member_api_docs, sort_constructors_first
library sliver_row_box;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ItemStatusSliverBox { inserting, inserted, remove, insertLater }

typedef BuildSliverBox<I> = Widget Function(
    {Animation? animation,
    required int index,
    required int length,
    required SliverBoxItemState<I> state});

class SliverRowBox<T, I> extends StatefulWidget {
  final List<SliverBoxItemState<T>> topList;
  final List<SliverBoxItemState<I>> itemList;
  final List<SliverBoxItemState<T>> bottomList;
  final BuildSliverBox<I> buildSliverBoxItem;
  final BuildSliverBox<T> buildSliverBoxTopBottom;
  final bool tt;
  final EdgeInsets paddingItem;
  final Duration duration;

  const SliverRowBox({
    Key? key,
    required this.topList,
    required this.itemList,
    required this.bottomList,
    required this.buildSliverBoxItem,
    required this.buildSliverBoxTopBottom,
    this.tt = true,
    this.paddingItem = const EdgeInsets.symmetric(horizontal: 16.0),
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<SliverRowBox<T, I>> createState() => SliverRowBoxState<T, I>();

  static SliverRowBoxState? of<T, I>(BuildContext context) {
    return context.findAncestorStateOfType<SliverRowBoxState<T, I>>();
  }
}

class SliverRowBoxState<T, I> extends State<SliverRowBox<T, I>>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? enableAnimation;
  bool maxItemsForAnimation = false;
  int maxItemsDuringAnimation = -1;

  AnimationController get animationController => _animationController ??=
      AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SliverRowBox<T, I> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void animateInsert() {
    if (_evaluateState()) {
      animationController.value = 0.0;

      enableAnimation = animationController
        ..drive<double>(CurveTween(curve: Curves.easeInOut));

      animationController.forward().then((value) {
        // animationController.removeListener(insertListener);
        for (SliverBoxItemState s in widget.itemList) {
          if (s.status == ItemStatusSliverBox.inserting ||
              s.status == ItemStatusSliverBox.insertLater) {
            s.status = ItemStatusSliverBox.inserted;
          }
        }
        if (mounted) {
          setState(() {
            maxItemsForAnimation = false;
          });
        }
      });
    }

    setState(() {});
  }

  void animateRemove() {
    if (_evaluateState()) {
      animationController.value = 1.0;

      enableAnimation = animationController
        ..drive<double>(CurveTween(curve: Curves.easeInOut));

      animationController.reverse().then((value) {
        debugPrint('then Reverse value');

        widget.itemList.removeWhere((SliverBoxItemState element) =>
            !element.single && element.status == ItemStatusSliverBox.remove);

        if (mounted && animationController.isDismissed) {
          setState(() {});
        }
      });
    }

    setState(() {});
  }

  bool get isAnimating => _animationController?.isAnimating ?? false;

  verwijder(SliverBoxItemState state) {
    setState(() {
      widget.itemList.remove(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (maxItemsForAnimation) {
    //   if (r != null) {
    //     final y = (r.parentData as SliverPhysicalParentData).paintOffset.dy;
    //     final vieportHeight = r.constraints.viewportMainAxisExtent;
    //     final height = vieportHeight * 1.25 - y;
    //     maxItemsDuringAnimation = height ~/ widget.heightItem + 1;
    //   }
    //   debugPrint('Maximum items during animation $maxItemsForAnimation');
    // } else {
    //   maxItemsDuringAnimation = -1;
    // }

    return SliverList(
        delegate: _SliverBoxRowSliverChildDelegate<T, I>(
      buildItem: _buildItem,
      buildTopBottom: _buildTopBottom,
      topList: widget.topList,
      itemList: widget.itemList,
      bottomList: widget.bottomList,
      maxItemsDuringAnimation: maxItemsDuringAnimation,
    ));
  }

  _evaluateState() {
    RenderSliverList? r = context.findRenderObject() as RenderSliverList?;
    double scrollOffset = r?.constraints.scrollOffset ?? 0.0;
    double viewportHeight = r?.constraints.viewportMainAxisExtent ?? 0.0;
    debugPrint('geinig ${r?.constraints.scrollOffset}');
    double additionalHeight = 0.0;

    bool animationVisible = false;

    final List<SliverBoxItemState> list = widget.itemList;
    int count = list.length;
    int i = 0;
    double end = 0.0;

    for (SliverBoxItemState s in widget.topList) {
      end += s.height;
    }

    double correct = 0.0;

    while (i < count) {
      final item = widget.itemList[i];
      final itemHeight = item.height;
      bool removed = false;

      if (end + itemHeight <= scrollOffset + correct) {
        switch (item.status) {
          case ItemStatusSliverBox.insertLater:
          case ItemStatusSliverBox.inserting:
            {
              item.status = ItemStatusSliverBox.inserted;
              correct += itemHeight;
              end += itemHeight;

              break;
            }
          case ItemStatusSliverBox.inserted:
            {
              end += itemHeight;
              break;
            }
          case ItemStatusSliverBox.remove:
            {
              correct -= itemHeight;
              list.removeAt(i);
              removed = true;
              break;
            }
        }
      } else if (end > scrollOffset + correct + viewportHeight) {
        switch (item.status) {
          case ItemStatusSliverBox.insertLater:
          case ItemStatusSliverBox.inserting:
            {
              item.status = ItemStatusSliverBox.inserted;
              end += itemHeight;
              break;
            }
          case ItemStatusSliverBox.inserted:
            {
              end += itemHeight;
              break;
            }
          case ItemStatusSliverBox.remove:
            {
              list.removeAt(i);
              removed = true;
              break;
            }
        }
      } else {
        if (item.status == ItemStatusSliverBox.inserting) {
          if (end + additionalHeight >
              scrollOffset + correct + viewportHeight) {
            item.status = ItemStatusSliverBox.insertLater;
          }
          additionalHeight += itemHeight;
          animationVisible = true;
        } else if (item.status == ItemStatusSliverBox.remove) {
          end += itemHeight;
          animationVisible = true;
        } else {
          end += itemHeight;
        }
      }

      if (removed) {
        count--;
      } else {
        i++;
      }
    }

    if (correct != 0.0) {
      final position = Scrollable.of(context)?.position;

      if (position != null) {
        position.correctBy(correct);

        position.animateTo(position.pixels + (correct > 0.0 ? -30 : 30),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
    }

    return animationVisible;
  }

  Widget _buildItem(
      {required BuildContext context,
      required SliverBoxItemState<I> state,
      required int index,
      required int length}) {
    var a = enableAnimation;

    a = (!state.single && (state.status == ItemStatusSliverBox.inserting) ||
            state.status == ItemStatusSliverBox.remove)
        ? a
        : null;

    return widget.buildSliverBoxItem(
        index: index, length: length, state: state, animation: a);
  }

  Widget _buildTopBottom(
      {required BuildContext context,
      required SliverBoxItemState<T> state,
      required int index,
      required int length}) {
    return widget.buildSliverBoxTopBottom(
        index: index, length: length, state: state);
  }
}

class _SliverBoxRowSliverChildDelegate<T, I> extends SliverChildDelegate {
  final List<SliverBoxItemState<T>> topList;
  final List<SliverBoxItemState<I>> itemList;
  final List<SliverBoxItemState<T>> bottomList;
  final int maxItemsDuringAnimation;

  final Widget Function(
      {required BuildContext context,
      required SliverBoxItemState<T> state,
      required int index,
      required int length}) buildTopBottom;

  final Widget Function(
      {required BuildContext context,
      required SliverBoxItemState<I> state,
      required int index,
      required int length}) buildItem;

  _SliverBoxRowSliverChildDelegate({
    required this.topList,
    required this.itemList,
    required this.bottomList,
    required this.buildTopBottom,
    required this.buildItem,
    required this.maxItemsDuringAnimation,
  });

  int skip = 0;

  @override
  Widget? build(BuildContext context, int index) {
    final topLength = topList.length;
    int itemLength = itemList.length;
    final bottomLength = bottomList.length;

    if (index == -1) {
      return null;
    }

    // if (maxItemsDuringAnimation != -1 && itemLength > maxItemsDuringAnimation) {
    //   itemLength = maxItemsDuringAnimation;
    // }

    if (index < topLength) {
      return buildTopBottom(
          context: context,
          state: topList[index],
          index: index,
          length: topLength);
    }

    index -= topLength;

    while (index + skip < itemLength) {
      if (itemList[index].status == ItemStatusSliverBox.insertLater) {
        skip++;
      } else {
        return buildItem(
            context: context,
            state: itemList[index + skip],
            index: index + skip,
            length: itemLength);
      }
    }

    index -= itemLength + skip;

    if (index < bottomLength) {
      return buildTopBottom(
          context: context,
          state: bottomList[index],
          index: index,
          length: bottomList.length);
    }

    return null;
  }

  @override
  int? get estimatedChildCount =>
      topList.length + itemList.length - skip + bottomList.length;

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return true;
  }
}

class SliverBoxItemState<T> {
  ItemStatusSliverBox status;
  bool single;
  T value;
  String key;
  double height;

  SliverBoxItemState({
    required this.status,
    required this.single,
    required this.value,
    required this.key,
    required this.height,
  });
}
