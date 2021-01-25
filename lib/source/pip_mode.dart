import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../classes/picture_in_picture.dart';

class PIPMode extends Disposable {
  final BuildContext context;
  OverlayState _overlayState;
  OverlayEntry _overlayEntry;

  PIPMode({@required this.context}) : assert(context != null) {
    _overlayState = Overlay.of(context);
  }

  void createPIP(PictureInPicture child, {bool allowMultipleWindows: false}) {
    if (!allowMultipleWindows && _overlayEntry != null) throw _error();
    _overlayEntry = new OverlayEntry(builder: (_) => child, maintainState: true);
    _overlayState.insert(_overlayEntry);
  }

  void closePIP() {
    _overlayEntry.remove();
    _overlayEntry = null;
  }

  String _error() {
    return "Múltiplas janelas instanciadas.\n\n"
        "Se dejesa muitas janelas, tente alterar o parâmetro 'allowMultipleWindows' para true.";
  }

  @override
  void dispose() {}
}
