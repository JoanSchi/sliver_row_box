library sliver_row_box;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'src/scale_size_transition.dart';

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
  final bool visible;
  final bool visibleAnimated;
  final int maximumItems;
  final double heightItem;
  final EdgeInsets paddingItem;
  final Duration duration;

  const SliverRowBox({
    Key? key,
    required this.topList,
    required this.itemList,
    required this.bottomList,
    required this.buildSliverBoxItem,
    required this.buildSliverBoxTopBottom,
    this.visible = true,
    this.visibleAnimated = false,
    this.maximumItems = -1,
    required this.heightItem,
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
  AnimationController? animationController;
  Animation<double>? enableAnimation;
  bool maxItemsForAnimation = false;
  int maxItemsDuringAnimation = -1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    checkAnimation();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SliverRowBox<T, I> oldWidget) {
    checkAnimation();
    if (widget.visibleAnimated) {
      if (widget.visible) {
        animationController?.forward();
      } else {
        animationController?.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  checkAnimation() {
    if (widget.visibleAnimated) {
      if (animationController == null) {
        maxItemsForAnimation = !widget.visible;
        animationController = AnimationController(
            value: widget.visible ? 1.0 : 0.0,
            vsync: this,
            duration: widget.duration);
        enableAnimation = animationController!
            .drive<double>(CurveTween(curve: Curves.easeInOut))
          ..addListener(() {
            if ((enableAnimation!.value != 1.0) != maxItemsForAnimation) {
              setState(() {
                maxItemsForAnimation = !maxItemsForAnimation;
              });
            }
          });
      } else if (animationController?.duration != widget.duration) {
        animationController?.duration = widget.duration;
      }
    } else if (animationController != null) {
      maxItemsForAnimation = false;
      animationController?.dispose();
      animationController = null;
      enableAnimation = null;
    }
  }

  verwijder(SliverBoxItemState state) {
    setState(() {
      widget.itemList.remove(state);
    });
  }

  @override
  Widget build(BuildContext context) {
    RenderSliverList? r = context.findRenderObject() as RenderSliverList?;
    debugPrint('geinig ${r?.constraints.scrollOffset}');

    if (maxItemsForAnimation) {
      if (r != null) {
        final y = (r.parentData as SliverPhysicalParentData).paintOffset.dy;
        final vieportHeight = r.constraints.viewportMainAxisExtent;
        final height = vieportHeight * 1.25 - y;
        maxItemsDuringAnimation = height ~/ widget.heightItem + 1;
      }
      debugPrint('Maximum items during animation $maxItemsForAnimation');
    } else {
      maxItemsDuringAnimation = -1;
    }

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

  Widget _buildItem(
      {required BuildContext context,
      required SliverBoxItemState<I> state,
      required int index,
      required int length}) {
    return widget.buildSliverBoxItem(
        index: index, length: length, state: state, animation: enableAnimation);
  }

  Widget _buildTopBottom(
      {required BuildContext context,
      required SliverBoxItemState<T> state,
      required int index,
      required int length}) {
    return widget.buildSliverBoxTopBottom(
        animation: enableAnimation, index: index, length: length, state: state);
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

  @override
  Widget? build(BuildContext context, int index) {
    final topLength = topList.length;
    int itemLength = itemList.length;
    final bottomLength = bottomList.length;

    if (index == -1) {
      return null;
    }

    if (maxItemsDuringAnimation != -1 && itemLength > maxItemsDuringAnimation) {
      itemLength = maxItemsDuringAnimation;
    }

    if (index < topLength) {
      return buildTopBottom(
          context: context,
          state: topList[index],
          index: index,
          length: topLength);
    }

    index -= topLength;

    if (index < itemLength) {
      return buildItem(
          context: context,
          state: itemList[index],
          index: index,
          length: itemLength);
    }

    index -= itemLength;

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
  bool shouldRebuild(SliverChildDelegate oldDelegate) {
    return true;
  }
}

// class VisibleAnimatedSliverRowItem extends StatelessWidget {
//   final Animation? enableAnimation;
//   final Widget child;

//   const VisibleAnimatedSliverRowItem({
//     Key? key,
//     this.enableAnimation,
//     required this.child,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final a = enableAnimation;

//     if (a != null) {
//       return AnimatedBuilder(
//           animation: a,
//           child: child,
//           builder: (BuildContext context, Widget? child) => a.value == 0.0
//               ? const SizedBox.shrink()
//               : ScaleResized(scale: a.value, child: child));
//     } else {
//       return child;
//     }
//   }
// }

class SliverBoxItemState<T> {
  double insertRemoveAnimation;
  T value;
  bool enabled;
  String key;

  SliverBoxItemState({
    required this.key,
    required this.insertRemoveAnimation,
    required this.value,
    required this.enabled,
  });

  AnimationStatus animationAction() {
    if (enabled && insertRemoveAnimation != 1.0) {
      return AnimationStatus.forward;
    } else if (!enabled && insertRemoveAnimation != 0.0) {
      return AnimationStatus.reverse;
    } else {
      return AnimationStatus.completed;
    }
  }
}
