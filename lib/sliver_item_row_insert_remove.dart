import 'package:flutter/widgets.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/src/scale_size_transition.dart';

class InsertRemoveVisibleAnimatedSliverRowItem extends StatelessWidget {
  final Animation? animation;
  final Widget child;
  final SliverBoxItemState state;

  const InsertRemoveVisibleAnimatedSliverRowItem({
    required Key key,
    this.animation,
    required this.child,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final a = animation;

    if (state.single) {
      return SingleSliverItemRowAnimation(
        state: state,
        child: child,
      );
    } else if (a != null) {
      return AnimatedBuilder(
          animation: a,
          child: child,
          builder: (BuildContext context, Widget? child) {
            final scale = a.value;
            return ScaleResized(scale: scale, child: child);
          });
    } else {
      return child;
    }
  }
}

class MultiSliverItemRowAnimation extends AnimatedWidget {
  final Widget child;

  const MultiSliverItemRowAnimation({
    super.key,
    required super.listenable,
    required this.child,
  });

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return ScaleResized(scale: _progress.value, child: child);
  }
}

class SingleSliverItemRowAnimation extends StatefulWidget {
  final SliverBoxItemState state;
  final Widget child;

  const SingleSliverItemRowAnimation({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  State<SingleSliverItemRowAnimation> createState() =>
      _SingleSliverItemRowAnimationState();
}

class _SingleSliverItemRowAnimationState
    extends State<SingleSliverItemRowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
      value: widget.state.status == ItemStatusSliverBox.insert ? 0.0 : 1.0,
      vsync: this,
      duration: const Duration(milliseconds: 200))
    ..addListener(() {
      if (animation.value == 0.0) {
      } else {
        setState(() {});
      }
    });

  late Animation animation =
      controller.drive(CurveTween(curve: Curves.easeInOut));

  @override
  void didChangeDependencies() {
    checkAnimation();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(SingleSliverItemRowAnimation oldWidget) {
    checkAnimation();
    super.didUpdateWidget(oldWidget);
  }

  checkAnimation() {
    switch (widget.state.status) {
      case ItemStatusSliverBox.insert:
        if (controller.status != AnimationStatus.forward) {
          controller.forward().then((value) {
            widget.state.single = false;
          });
        }
        break;

      case ItemStatusSliverBox.remove:
        if (controller.status != AnimationStatus.reverse) {
          controller.reverse().then(
              (value) => SliverRowBox.of(context)?.verwijder(widget.state));
        }
        break;
      default:
        {}
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleResized(scale: controller.value, child: widget.child);
  }
}
