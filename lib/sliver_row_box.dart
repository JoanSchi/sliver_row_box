// ignore_for_file: public_member_api_docs, sort_constructors_first
library sliver_row_box;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum ItemStatusSliverBox { insert, completed, remove, insertLater }

enum SliverBoxAction { insert, remove, nothing }

typedef IgnorePointer = void Function(bool ignore);

typedef BuildSliverBox<I> = Widget Function(
    {Animation? animation,
    required int index,
    required int length,
    required SliverBoxItemState<I> state});

Widget _empty(
    {Animation? animation,
    required int index,
    required int length,
    required SliverBoxItemState state}) {
  return const SizedBox.shrink();
}

class SliverRowBox<T, I> extends StatefulWidget {
  final List<SliverBoxItemState<T>> topList;
  final List<SliverBoxItemState<I>> itemList;
  final List<SliverBoxItemState<T>> bottomList;
  final BuildSliverBox<I> buildSliverBoxItem;
  final BuildSliverBox<T> buildSliverBoxTopBottom;
  final EdgeInsets paddingItem;
  final Duration duration;
  final SliverBoxAction sliverBoxAction;
  final IgnorePointer? ignorePointer;

  const SliverRowBox({
    Key? key,
    this.topList = const [],
    required this.itemList,
    this.bottomList = const [],
    required this.buildSliverBoxItem,
    this.buildSliverBoxTopBottom = _empty,
    this.sliverBoxAction = SliverBoxAction.nothing,
    this.paddingItem = const EdgeInsets.symmetric(horizontal: 16.0),
    this.duration = const Duration(milliseconds: 300),
    this.ignorePointer,
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
  bool ignorePointer = false;

  AnimationController get animationController => _animationController ??=
      AnimationController(vsync: this, duration: widget.duration)
        ..addListener(() {
          final position = scrollPostion;

          if (position != null) {
            if (position.pixels < position.minScrollExtent) {
              position.jumpTo(position.minScrollExtent);
            } else if (position.pixels > position.maxScrollExtent) {
              position.jumpTo(position.maxScrollExtent);
            }
          }
        });

  ScrollPosition? scrollPostion;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollPostion = Scrollable.of(context)?.position;
  }

  @override
  void didUpdateWidget(SliverRowBox<T, I> oldWidget) {
    switch (widget.sliverBoxAction) {
      case SliverBoxAction.insert:
        _animateInsert();
        break;
      case SliverBoxAction.remove:
        _animateRemove();
        break;
      case SliverBoxAction.nothing:
        break;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void animateInsert() {
    setState(() {
      _animateInsert();
    });
  }

  void _animateInsert() {
    if (_evaluateState()) {
      animationController.value = 0.0;

      enableAnimation = animationController
        ..drive<double>(CurveTween(curve: Curves.easeInOut));

      animationController.forward().then((value) {
        for (SliverBoxItemState s in widget.itemList) {
          if (s.status == ItemStatusSliverBox.insert ||
              s.status == ItemStatusSliverBox.insertLater) {
            s.status = ItemStatusSliverBox.completed;
          }
        }
        if (ignorePointer) {
          ignorePointer = false;
          widget.ignorePointer?.call(false);
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _animateRemove() {
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
  }

  animateRemove() {
    setState(() {
      _animateRemove();
    });
  }

  bool get isAnimating => _animationController?.isAnimating ?? false;

  verwijder(SliverBoxItemState state) {
    setState(() {
      widget.itemList.remove(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Modify/implement SliverFixedExtentList for speed

    return SliverList(
        delegate: _SliverBoxRowSliverChildDelegate<T, I>(
      buildItem: _buildItem,
      buildTopBottom: _buildTopBottom,
      topList: widget.topList,
      itemList: widget.itemList,
      bottomList: widget.bottomList,
    ));
  }

  _evaluateState() {
    RenderSliverList? r = context.findRenderObject() as RenderSliverList?;
    double scrollOffset = r?.constraints.scrollOffset ?? 0.0;
    double viewportHeight = r?.constraints.viewportMainAxisExtent ?? 0.0;
    debugPrint(
        'Evaluate scrollOffset: $scrollOffset, viewportHeight: $viewportHeight');
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
          case ItemStatusSliverBox.insert:
            {
              item.status = ItemStatusSliverBox.completed;
              correct += itemHeight;
              end += itemHeight;

              break;
            }
          case ItemStatusSliverBox.completed:
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
          case ItemStatusSliverBox.insert:
            {
              item.status = ItemStatusSliverBox.completed;
              end += itemHeight;
              break;
            }
          case ItemStatusSliverBox.completed:
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
        if (item.status == ItemStatusSliverBox.insert) {
          if (end + additionalHeight >
              scrollOffset + correct + viewportHeight) {
            item.status = ItemStatusSliverBox.insertLater;

            ignorePointer = true;
            widget.ignorePointer?.call(true);
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

    a = (!state.single && (state.status == ItemStatusSliverBox.insert) ||
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

    index -= itemLength - skip;

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
      topList.length + itemList.length + bottomList.length;

  @override
  double? estimateMaxScrollOffset(
    int firstIndex,
    int lastIndex,
    double leadingScrollOffset,
    double trailingScrollOffset,
  ) {
    return null;
  }

  @override
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return true;
  }
}

class SliverBoxItemState<T> {
  ItemStatusSliverBox status;
  bool single;
  bool editing;
  T value;
  String key;
  double height;

  SliverBoxItemState({
    this.status = ItemStatusSliverBox.completed,
    this.single = false,
    this.editing = false,
    required this.value,
    required this.key,
    required this.height,
  });
}
