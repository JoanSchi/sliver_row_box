import 'package:flutter/widgets.dart';
import 'package:sliver_row_box/sliver_row_box.dart';
import 'package:sliver_row_box/src/scale_size_transition.dart';

class InsertRemoveVisibleAnimatedSliverRowItem extends StatelessWidget {
  final Animation? enableAnimation;
  final Widget child;
  final SliverBoxItemState state;

  const InsertRemoveVisibleAnimatedSliverRowItem({
    Key? key,
    this.enableAnimation,
    required this.child,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final a = enableAnimation;

    if (a != null) {
      return AnimatedBuilder(
          key: Key('ea_${state.key}'),
          animation: a,
          child: child,
          builder: (BuildContext context, Widget? child) {
            final scale = a.value;
            return ScaleResized(scale: scale, child: child);
          });
    } else {
      return individual();
    }
  }

  Widget individual() {
    if (state.enabled && state.insertRemoveAnimation == 1.0) {
      return child;
    } else {
      return SliverItemRowAnimation(
        key: Key('a_${state.key}'),
        state: state,
        child: child,
      );
    }
  }
}

class SliverItemRowAnimation extends StatefulWidget {
  final SliverBoxItemState state;
  final Widget child;

  const SliverItemRowAnimation({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  State<SliverItemRowAnimation> createState() => _SliverItemRowAnimationState();
}

class _SliverItemRowAnimationState extends State<SliverItemRowAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(
      value: widget.state.insertRemoveAnimation,
      vsync: this,
      duration: const Duration(milliseconds: 200))
    ..addListener(() {
      if (animation.value == 0.0 && !widget.state.enabled) {
        SliverRowBox.of(context)?.verwijder(widget.state);
      } else {
        setState(() {
          widget.state.insertRemoveAnimation = animation.value;
        });
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
  void didUpdateWidget(SliverItemRowAnimation oldWidget) {
    checkAnimation();
    super.didUpdateWidget(oldWidget);
  }

  checkAnimation() {
    switch (widget.state.animationAction()) {
      case AnimationStatus.forward:
        controller.forward();
        break;
      case AnimationStatus.reverse:
        controller.reverse();
        break;
      default:
        {}
        break;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleResized(
        scale: widget.state.insertRemoveAnimation, child: widget.child);
  }
}
