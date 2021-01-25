import 'package:flutter/material.dart';

import '../enums/enums.dart';
import '../functions/functions.dart';

class PictureInPicture extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double floatingWidth;
  final double floatingHeight;
  final int animationDuration;
  final bool avoidKeyboard;

  final Widget Function(
    BuildContext context,
    bool isFloating,
  ) builder;

  const PictureInPicture({
    Key key,
    @required this.builder,
    this.initialCorner: PIPViewCorner.topRight,
    this.floatingWidth,
    this.animationDuration: 500,
    this.floatingHeight,
    this.avoidKeyboard: true,
  }) : super(key: key);

  @override
  _PictureInPictureState createState() => _PictureInPictureState();

  static _PictureInPictureState of(BuildContext context) {
    return context.findAncestorStateOfType<_PictureInPictureState>();
  }
}

class _PictureInPictureState extends State<PictureInPicture>
    with TickerProviderStateMixin {
  AnimationController _toggleFloatingAnimationController;
  AnimationController _dragAnimationController;
  Map<PIPViewCorner, Offset> _offsets = {};
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isFloating = false;
  PIPViewCorner _corner;

  @override
  void initState() {
    super.initState();
    _corner = widget.initialCorner;
    _toggleFloatingAnimationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    _dragAnimationController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _toggleFloatingAnimationController.dispose();
    _dragAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var windowPadding = mediaQuery.padding;
    if (widget.avoidKeyboard) {
      windowPadding += mediaQuery.viewInsets;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        double floatingWidth = widget.floatingWidth;
        double floatingHeight = widget.floatingHeight;

        if (floatingWidth == null && floatingHeight != null) {
          floatingWidth = width / height * floatingHeight;
        }
        floatingWidth ??= 100.0;
        if (floatingHeight == null) {
          floatingHeight = height / width * floatingWidth;
        }

        final floatingWidgetSize = Size(floatingWidth, floatingHeight);
        final fullWidgetSize = Size(width, height);

        _updateCornersOffsets(
          spaceSize: fullWidgetSize,
          windowPadding: windowPadding,
          widgetSize: floatingWidgetSize,
        );

        final calculatedOffset = _offsets[_corner];

        // BoxFit.cover
        final widthRatio = floatingWidth / width;
        final heightRatio = floatingHeight / height;
        final scaledDownScale = widthRatio > heightRatio
            ? floatingWidgetSize.width / fullWidgetSize.width
            : floatingWidgetSize.height / fullWidgetSize.height;

        return Stack(
          children: <Widget>[
            AnimatedBuilder(
              animation: Listenable.merge([
                _toggleFloatingAnimationController,
                _dragAnimationController,
              ]),
              builder: (context, child) {
                final animationCurve = CurveTween(curve: Curves.easeInOutQuad);
                final dragAnimationValue = animationCurve.transform(
                  _dragAnimationController.value,
                );
                final toggleFloatingAnimationValue = animationCurve.transform(
                  _toggleFloatingAnimationController.value,
                );

                final floatingOffset = _isDragging
                    ? _dragOffset
                    : Tween<Offset>(
                        begin: _dragOffset,
                        end: calculatedOffset,
                      ).transform(
                        _dragAnimationController.isAnimating
                            ? dragAnimationValue
                            : toggleFloatingAnimationValue,
                      );
                final borderRadius = Tween<double>(begin: 0, end: 15)
                    .transform(toggleFloatingAnimationValue);
                final width = Tween<double>(
                  begin: fullWidgetSize.width,
                  end: floatingWidgetSize.width,
                ).transform(toggleFloatingAnimationValue);
                final height = Tween<double>(
                  begin: fullWidgetSize.height,
                  end: floatingWidgetSize.height,
                ).transform(toggleFloatingAnimationValue);
                final scale = Tween<double>(
                  begin: 1,
                  end: scaledDownScale,
                ).transform(toggleFloatingAnimationValue);
                return Positioned(
                  left: floatingOffset.dx,
                  top: floatingOffset.dy,
                  child: GestureDetector(
                    onPanStart: _isFloating ? _onPanStart : null,
                    onPanUpdate: _isFloating ? _onPanUpdate : null,
                    onPanCancel: _isFloating ? _onPanCancel : null,
                    onPanEnd: _isFloating ? _onPanEnd : null,
                    onTap: _isFloating ? stopFloating : null,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.25),
                            spreadRadius: 1.0,
                            blurRadius: 10.0,
                          ),
                        ],
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(borderRadius),
                      ),
                      width: width,
                      height: height,
                      child: Transform.scale(
                        scale: scale,
                        child: OverflowBox(
                          maxHeight: fullWidgetSize.height,
                          maxWidth: fullWidgetSize.width,
                          child: IgnorePointer(
                            ignoring: _isFloating,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Builder(
                builder: (context) => widget.builder(context, _isFloating),
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isAnimating() {
    return _toggleFloatingAnimationController.isAnimating ||
        _dragAnimationController.isAnimating;
  }

  void _updateCornersOffsets(
      {Size spaceSize, Size widgetSize, EdgeInsets windowPadding}) {
    _offsets = calculateOffsets(
      spaceSize: spaceSize,
      widgetSize: widgetSize,
      windowPadding: windowPadding,
    );
  }

  void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void startFloating() {
    if (_isAnimating()) return;
    dismissKeyboard(context);
    setState(() => _isFloating = true);
    _toggleFloatingAnimationController.forward();
  }

  void stopFloating() {
    if (_isAnimating()) return;
    dismissKeyboard(context);
    setState(() => _isFloating = false);
    _toggleFloatingAnimationController.reverse();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = _dragOffset.translate(details.delta.dx, details.delta.dy);
    });
  }

  void _onPanCancel() {
    if (!_isDragging) return;
    setState(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
      _isDragging = false;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;

    final nearestCorner = calculateNearestCorner(
      offset: _dragOffset,
      offsets: _offsets,
    );
    setState(() {
      _corner = nearestCorner;
      _isDragging = false;
    });
    _dragAnimationController.forward().whenCompleteOrCancel(() {
      _dragAnimationController.value = 0;
      _dragOffset = Offset.zero;
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating()) return;
    setState(() {
      _dragOffset = _offsets[_corner];
      _isDragging = true;
    });
  }
}
