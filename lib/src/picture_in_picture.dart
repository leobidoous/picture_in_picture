import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:picture_in_picture/functions/functions.dart';

import '../enums/enums.dart';

class PictureInPicture extends StatefulWidget {
  final PIPViewCorner initialCorner;
  final double floatingWidth;
  final double floatingHeight;
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
  OverlayEntry _detailsOverlayEntry;
  OverlayState _overlayState;

  AnimationController _toggleFloatingAnimationController;
  AnimationController _dragAnimationController;
  Map<PIPViewCorner, Offset> _offsets = {};
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  PIPViewCorner _corner;
  Widget _bottomView;

  @override
  void initState() {
    _overlayState = Overlay.of(context);
    super.initState();
    _corner = widget.initialCorner;
    _toggleFloatingAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _dragAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var windowPadding = mediaQuery.padding;
    if (widget.avoidKeyboard) {
      windowPadding += mediaQuery.viewInsets;
    }
    final isFloating = _bottomView != null;

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
          widgetSize: floatingWidgetSize,
          windowPadding: windowPadding,
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
                final animationCurve = CurveTween(
                  curve: Curves.easeInOutQuad,
                );
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
                final borderRadius = Tween<double>(
                  begin: 0,
                  end: 10,
                ).transform(toggleFloatingAnimationValue);
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
                    onPanStart: isFloating ? _onPanStart : null,
                    onPanUpdate: isFloating ? _onPanUpdate : null,
                    onPanCancel: isFloating ? _onPanCancel : null,
                    onPanEnd: isFloating ? _onPanEnd : null,
                    onTap: isFloating ? stopFloating : null,
                    child: Material(
                      elevation: 10,
                      borderRadius: BorderRadius.circular(borderRadius),
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
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
                              ignoring: isFloating,
                              child: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Builder(
                builder: (context) => widget.builder(context, isFloating),
              ),
            ),
            // if (isFloating)
            //   IgnorePointer(
            //     ignoring: isFloating,
            //     child: Navigator(
            //       onGenerateRoute: (settings) {
            //         return MaterialPageRoute(builder: (_) => _bottomView);
            //       },
            //     ),
            //   ),
          ],
        );
      },
    );
  }

  void _updateCornersOffsets(
      {Size spaceSize, Size widgetSize, EdgeInsets windowPadding}) {
    _offsets = calculateOffsets(
      spaceSize: spaceSize,
      widgetSize: widgetSize,
      windowPadding: windowPadding,
    );
  }

  bool _isAnimating() {
    return _toggleFloatingAnimationController.isAnimating ||
        _dragAnimationController.isAnimating;
  }

  void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void startFloating(Widget widget) {
    if (_isAnimating() || _bottomView != null) return;
    dismissKeyboard(context);
    setState(() {
      _bottomView = widget;
    });
    _toggleFloatingAnimationController.forward();
  } 

  void stopFloating() {
    if (_isAnimating() || _bottomView == null) return;
    dismissKeyboard(context);
    _toggleFloatingAnimationController.reverse().whenCompleteOrCancel(() {
      if (mounted) {
        setState(() {
          _bottomView = null;
        });
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragOffset = _dragOffset.translate(
        details.delta.dx,
        details.delta.dy,
      );
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
