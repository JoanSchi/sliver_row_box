import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SizedSliverBox extends SingleChildRenderObjectWidget {
  const SizedSliverBox({super.key, required this.height, super.child});

  final double height;

  @override
  RenderSizeSliverBox createRenderObject(BuildContext context) {
    return RenderSizeSliverBox(
      height: height,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSizeSliverBox renderObject) {
    renderObject.height = height;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final DiagnosticLevel level;
    if (height == double.infinity || height == 0.0) {
      level = DiagnosticLevel.hidden;
    } else {
      level = DiagnosticLevel.info;
    }

    properties.add(
        DoubleProperty('height', height, defaultValue: null, level: level));
  }
}

class RenderSizeSliverBox extends RenderProxyBox {
  /// Creates a render box that constrains its child.
  ///
  /// The [additionalConstraints] argument must not be null and must be valid.
  RenderSizeSliverBox({
    RenderBox? child,
    required double height,
  })  : _height = height,
        super(child);

  /// Additional constraints to apply to [child] during layout.
  double get height => _height;
  double _height;
  set height(double value) {
    if (_height == value) {
      return;
    }
    _height = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return super.computeMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return super.computeMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    final double max = super.computeMaxIntrinsicHeight(width);
    return (max < height) ? max : _height;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    if (child != null) {
      child!.layout(constraints.tighten(height: height), parentUsesSize: false);
    }

    size = Size(constraints.maxWidth, _height);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, _height);
    // if (child != null) {
    //   return child!.getDryLayout(_additionalConstraints.enforce(constraints));
    // } else {
    //   return _additionalConstraints.enforce(constraints).constrain(Size.zero);
    // }
  }

  @override
  void debugPaintSize(PaintingContext context, Offset offset) {
    super.debugPaintSize(context, offset);
    assert(() {
      final Paint paint;
      if (child == null || child!.size.isEmpty) {
        paint = Paint()..color = const Color(0x90909090);
        context.canvas.drawRect(offset & size, paint);
      }
      return true;
    }());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('height', height));
  }
}
