// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_call_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$VideoCallController on _VideoCallControllerBase, Store {
  final _$permissionStatusAtom =
      Atom(name: '_VideoCallControllerBase.permissionStatus');

  @override
  PermissionStatus get permissionStatus {
    _$permissionStatusAtom.reportRead();
    return super.permissionStatus;
  }

  @override
  set permissionStatus(PermissionStatus value) {
    _$permissionStatusAtom.reportWrite(value, super.permissionStatus, () {
      super.permissionStatus = value;
    });
  }

  final _$canInitCallAtom = Atom(name: '_VideoCallControllerBase.canInitCall');

  @override
  bool get canInitCall {
    _$canInitCallAtom.reportRead();
    return super.canInitCall;
  }

  @override
  set canInitCall(bool value) {
    _$canInitCallAtom.reportWrite(value, super.canInitCall, () {
      super.canInitCall = value;
    });
  }

  final _$hasVideoPermissionAtom =
      Atom(name: '_VideoCallControllerBase.hasVideoPermission');

  @override
  bool get hasVideoPermission {
    _$hasVideoPermissionAtom.reportRead();
    return super.hasVideoPermission;
  }

  @override
  set hasVideoPermission(bool value) {
    _$hasVideoPermissionAtom.reportWrite(value, super.hasVideoPermission, () {
      super.hasVideoPermission = value;
    });
  }

  final _$hasAudioPermissionAtom =
      Atom(name: '_VideoCallControllerBase.hasAudioPermission');

  @override
  bool get hasAudioPermission {
    _$hasAudioPermissionAtom.reportRead();
    return super.hasAudioPermission;
  }

  @override
  set hasAudioPermission(bool value) {
    _$hasAudioPermissionAtom.reportWrite(value, super.hasAudioPermission, () {
      super.hasAudioPermission = value;
    });
  }

  final _$switchVideosAtom =
      Atom(name: '_VideoCallControllerBase.switchVideos');

  @override
  bool get switchVideos {
    _$switchVideosAtom.reportRead();
    return super.switchVideos;
  }

  @override
  set switchVideos(bool value) {
    _$switchVideosAtom.reportWrite(value, super.switchVideos, () {
      super.switchVideos = value;
    });
  }

  final _$videoEnabledAtom =
      Atom(name: '_VideoCallControllerBase.videoEnabled');

  @override
  bool get videoEnabled {
    _$videoEnabledAtom.reportRead();
    return super.videoEnabled;
  }

  @override
  set videoEnabled(bool value) {
    _$videoEnabledAtom.reportWrite(value, super.videoEnabled, () {
      super.videoEnabled = value;
    });
  }

  final _$audioEnabledAtom =
      Atom(name: '_VideoCallControllerBase.audioEnabled');

  @override
  bool get audioEnabled {
    _$audioEnabledAtom.reportRead();
    return super.audioEnabled;
  }

  @override
  set audioEnabled(bool value) {
    _$audioEnabledAtom.reportWrite(value, super.audioEnabled, () {
      super.audioEnabled = value;
    });
  }

  final _$cameraTypeAtom = Atom(name: '_VideoCallControllerBase.cameraType');

  @override
  CameraType get cameraType {
    _$cameraTypeAtom.reportRead();
    return super.cameraType;
  }

  @override
  set cameraType(CameraType value) {
    _$cameraTypeAtom.reportWrite(value, super.cameraType, () {
      super.cameraType = value;
    });
  }

  final _$fullScreenAtom = Atom(name: '_VideoCallControllerBase.fullScreen');

  @override
  bool get fullScreen {
    _$fullScreenAtom.reportRead();
    return super.fullScreen;
  }

  @override
  set fullScreen(bool value) {
    _$fullScreenAtom.reportWrite(value, super.fullScreen, () {
      super.fullScreen = value;
    });
  }

  final _$insideVideoAlignmentAtom =
      Atom(name: '_VideoCallControllerBase.insideVideoAlignment');

  @override
  Alignment get insideVideoAlignment {
    _$insideVideoAlignmentAtom.reportRead();
    return super.insideVideoAlignment;
  }

  @override
  set insideVideoAlignment(Alignment value) {
    _$insideVideoAlignmentAtom.reportWrite(value, super.insideVideoAlignment,
        () {
      super.insideVideoAlignment = value;
    });
  }

  final _$_VideoCallControllerBaseActionController =
      ActionController(name: '_VideoCallControllerBase');

  @override
  void onCalculateAlignment(BuildContext context, DraggableDetails details) {
    final _$actionInfo = _$_VideoCallControllerBaseActionController.startAction(
        name: '_VideoCallControllerBase.onCalculateAlignment');
    try {
      return super.onCalculateAlignment(context, details);
    } finally {
      _$_VideoCallControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  Timer onChangeFullScreenMode() {
    final _$actionInfo = _$_VideoCallControllerBaseActionController.startAction(
        name: '_VideoCallControllerBase.onChangeFullScreenMode');
    try {
      return super.onChangeFullScreenMode();
    } finally {
      _$_VideoCallControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
permissionStatus: ${permissionStatus},
canInitCall: ${canInitCall},
hasVideoPermission: ${hasVideoPermission},
hasAudioPermission: ${hasAudioPermission},
switchVideos: ${switchVideos},
videoEnabled: ${videoEnabled},
audioEnabled: ${audioEnabled},
cameraType: ${cameraType},
fullScreen: ${fullScreen},
insideVideoAlignment: ${insideVideoAlignment}
    ''';
  }
}
