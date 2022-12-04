import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class SizedSliverBox extends SingleChildRenderObjectWidget {
  /// Creates a fixed size box. The [width] and [height] parameters can be null
  /// to indicate that the size of the box should not be constrained in
  /// the corresponding dimension.
  const SizedSliverBox({super.key, this.width, this.height, super.child});

  /// If non-null, requires the child to have exactly this width.
  final double? width;

  /// If non-null, requires the child to have exactly this height.
  final double? height;

  @override
  RenderSizeSliverBox createRenderObject(BuildContext context) {
    return RenderSizeSliverBox(
      additionalConstraints: _additionalConstraints,
    );
  }

  BoxConstraints get _additionalConstraints {
    return BoxConstraints.tightFor(width: width, height: height);
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSizeSliverBox renderObject) {
    renderObject.additionalConstraints = _additionalConstraints;
  }

  @override
  String toStringShort() {
    final String type;
    if (width == double.infinity && height == double.infinity) {
      type = '${objectRuntimeType(this, 'SizedBox')}.expand';
    } else if (width == 0.0 && height == 0.0) {
      type = '${objectRuntimeType(this, 'SizedBox')}.shrink';
    } else {
      type = objectRuntimeType(this, 'SizedBox');
    }
    return key == null ? type : '$type-$key';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    final DiagnosticLevel level;
    if ((width == double.infinity && height == double.infinity) ||
        (width == 0.0 && height == 0.0)) {
      level = DiagnosticLevel.hidden;
    } else {
      level = DiagnosticLevel.info;
    }
    properties
        .add(DoubleProperty('width', width, defaultValue: null, level: level));
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
    required BoxConstraints additionalConstraints,
  })  : assert(additionalConstraints.debugAssertIsValid()),
        _additionalConstraints = additionalConstraints,
        super(child);

  /// Additional constraints to apply to [child] during layout.
  BoxConstraints get additionalConstraints => _additionalConstraints;
  BoxConstraints _additionalConstraints;
  set additionalConstraints(BoxConstraints value) {
    assert(value.debugAssertIsValid());
    if (_additionalConstraints == value) {
      return;
    }
    _additionalConstraints = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    if (_additionalConstraints.hasBoundedWidth &&
        _additionalConstraints.hasTightWidth) {
      return _additionalConstraints.minWidth;
    }
    final double width = super.computeMinIntrinsicWidth(height);
    assert(width.isFinite);
    if (!_additionalConstraints.hasInfiniteWidth) {
      return _additionalConstraints.constrainWidth(width);
    }
    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    if (_additionalConstraints.hasBoundedWidth &&
        _additionalConstraints.hasTightWidth) {
      return _additionalConstraints.minWidth;
    }
    final double width = super.computeMaxIntrinsicWidth(height);
    assert(width.isFinite);
    if (!_additionalConstraints.hasInfiniteWidth) {
      return _additionalConstraints.constrainWidth(width);
    }
    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    if (_additionalConstraints.hasBoundedHeight &&
        _additionalConstraints.hasTightHeight) {
      return _additionalConstraints.minHeight;
    }
    final double height = super.computeMinIntrinsicHeight(width);
    assert(height.isFinite);
    if (!_additionalConstraints.hasInfiniteHeight) {
      return _additionalConstraints.constrainHeight(height);
    }
    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    if (_additionalConstraints.hasBoundedHeight &&
        _additionalConstraints.hasTightHeight) {
      return _additionalConstraints.minHeight;
    }
    final double height = super.computeMaxIntrinsicHeight(width);
    assert(height.isFinite);
    if (!_additionalConstraints.hasInfiniteHeight) {
      return _additionalConstraints.constrainHeight(height);
    }
    return height;
  }

  @override
  void performLayout() {
    final BoxConstraints constraints = this.constraints;
    if (child != null) {
      child!.layout(_additionalConstraints.enforce(constraints),
          parentUsesSize: false);
    }

    size = Size(constraints.maxWidth, _additionalConstraints.maxHeight);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return Size(constraints.maxWidth, _additionalConstraints.maxHeight);
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
    properties.add(DiagnosticsProperty<BoxConstraints>(
        'additionalConstraints', additionalConstraints));
  }
}
