import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backdrop_state.dart';

class Backdrop extends ConsumerStatefulWidget {
  final Widget body;
  final Widget appBar;
  final Widget back;

  const Backdrop(
      {super.key,
      required this.body,
      required this.appBar,
      required this.back});

  @override
  ConsumerState<Backdrop> createState() => _BackdropState();
}

class _BackdropState extends ConsumerState<Backdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _easyInOutAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
        value: ref.read(dropBackdropProvider) ? 1.0 : 0.0,
        vsync: this,
        duration: const Duration(milliseconds: 200));
    super.initState();

    _easyInOutAnimation =
        CurveTween(curve: Curves.easeInOut).animate(_animationController.view);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(dropBackdropProvider, (previous, next) {
      if (next) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints contraints) {
        final layerHeight = contraints.maxHeight;
        const appBarSize = 56.0;

        Animation<RelativeRect> layerAnimation = RelativeRectTween(
          begin: const RelativeRect.fromLTRB(0.0, appBarSize, 0.0, 0.0),
          end: RelativeRect.fromLTRB(0.0, layerHeight - appBarSize, 0.0, 0.0),
        ).animate(_animationController.view);

        return Stack(
          children: [
            Positioned(
                key: const Key('appbar'),
                left: 0.0,
                top: 0.0,
                right: 0.0,
                height: appBarSize,
                child: widget.appBar),
            Positioned(
              key: const Key('back'),
              left: 0.0,
              top: appBarSize,
              right: 0.0,
              bottom: appBarSize,
              child: AnimatedBuilder(
                  animation: _easyInOutAnimation,
                  builder: ((context, child) => Opacity(
                      opacity: _easyInOutAnimation.value, child: child)),
                  child: widget.back),
            ),
            PositionedTransition(
              key: const Key('body'),
              rect: layerAnimation,
              child: widget.body,
            )
          ],
        );
      },
    );
  }
}
