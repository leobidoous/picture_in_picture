import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:mobx/mobx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picture_in_picture_example/app/app_controller.dart';
import 'package:picture_in_picture_example/app/core/enums/enums.dart';
import 'package:picture_in_picture_example/app/core/config/config.dart' as config;

part 'video_call_controller.g.dart';

@Injectable()
class VideoCallController = _VideoCallControllerBase with _$VideoCallController;

abstract class _VideoCallControllerBase with Store {

  final AppController appController = Modular.get<AppController>();
  RtcEngine rtcEngineClient;
  int uidUser;

  ObservableList usersOnline = ObservableList();
  Timer timer;

  BuildContext context;

  @observable
  PermissionStatus permissionStatus;
  @observable
  bool canInitCall = false;
  @observable
  bool hasVideoPermission = false;
  @observable
  bool hasAudioPermission = false;
  @observable
  bool switchVideos = false;
  @observable
  bool videoEnabled = true;
  @observable
  bool audioEnabled = true;
  @observable
  CameraType cameraType = CameraType.FRONT;
  @observable
  bool fullScreen = true;
  @observable
  Alignment insideVideoAlignment = Alignment.topLeft;

  Future<void> onCanInitCall() async {
    PermissionStatus _cameraStatus = await Permission.camera.status;
    if (_cameraStatus == PermissionStatus.granted) {
      hasVideoPermission = true;
    }
    PermissionStatus _microphoneStatus = await Permission.microphone.status;
    if (_microphoneStatus == PermissionStatus.granted) {
      hasAudioPermission = true;
    }

    if (hasVideoPermission && hasAudioPermission ) {
      canInitCall = true;
    } else {
      canInitCall = false;
    }
  }

  Future<void> onCheckAudioPermission() async {
    try {
      await Permission.microphone.request();
      PermissionStatus _microphoneStatus = await Permission.microphone.status;
      if (_microphoneStatus == PermissionStatus.granted) {
        hasAudioPermission = true;
      } else {
        permissionStatus = _microphoneStatus;
      }

      if (hasVideoPermission && hasAudioPermission ) {
        canInitCall = true;
      } else {
        canInitCall = false;
      }
    } catch (e) {
      print("Erro ao checar permissões: $e");
    }
  }

  Future<void> onCheckVideoPermission() async {
    try {
      await Permission.camera.request();
      PermissionStatus _cameraStatus = await Permission.camera.status;
      if (_cameraStatus == PermissionStatus.granted) {
        hasVideoPermission = true;
      } else {
        permissionStatus = _cameraStatus;
      }

      if (hasVideoPermission && hasAudioPermission ) {
        canInitCall = true;
      } else {
        canInitCall = false;
      }
    } catch (e) {
      print("Erro ao checar permissões: $e");
    }
  }

  Future<void> initVideoCall(String channel, int userUid) async {
    if (rtcEngineClient != null) return;
    try {
      rtcEngineClient = await RtcEngine.create(config.appId);
      rtcEngineClient.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: joinChannelSuccess,
          userJoined: userJoined,
          userOffline: userOffline,
        ),
      );
      await rtcEngineClient.enableVideo();
      await rtcEngineClient.joinChannel(null, channel, null, userUid);
    } catch (e) {
      print("Erro ao iniciar video chamada: $e");
    }
  }

  void joinChannelSuccess(String channel, int uid, int elapsed) {
    print('joinChannelSuccess $channel $uid');
    uidUser = uid;
    if (!usersOnline.contains(uidUser)) usersOnline.add(uidUser);
    if (usersOnline.length > 1) timer = onChangeFullScreenMode();
  }

  void userJoined(int uid, int elapsed) {
    print('userJoined $uid');
    usersOnline.add(uid);
    timer = onChangeFullScreenMode();
  }

  void userOffline(int uid, UserOfflineReason reason) {
    print('userOffline $uid');
    usersOnline.remove(uid);
    if (usersOnline.length == 1) {
      if (usersOnline.first == uidUser) {
        Navigator.pop(context);
      }
    }
  }

  @action
  void onCalculateAlignment(BuildContext context, DraggableDetails details) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    if (details.offset.dy > _height / 2) {
      if (details.offset.dx > _width / 2) {
        insideVideoAlignment = Alignment.bottomRight;
      } else {
        insideVideoAlignment = Alignment.bottomLeft;
      }
    } else {
      if (details.offset.dx > _width / 2) {
        insideVideoAlignment = Alignment.topRight;
      } else {
        insideVideoAlignment = Alignment.topLeft;
      }
    }
  }

  @action
  Timer onChangeFullScreenMode() {
    final Function _hidden = () {
      if (usersOnline.isEmpty) return;
      fullScreen = false;
      SystemChrome.setEnabledSystemUIOverlays([]);
    };
    if (fullScreen) {
      _hidden();
      return null;
    } else {
      SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.bottom, SystemUiOverlay.top],
      );
      fullScreen = true;
      return Timer(Duration(milliseconds: 2500), _hidden);
    }
  }

  Future<void> onChangeCameraType() async {
    if (timer != null) timer.cancel();
    fullScreen = false;
    timer = onChangeFullScreenMode();
    await rtcEngineClient.switchCamera();
    if (cameraType == CameraType.FRONT)
      cameraType = CameraType.BACK;
    else
      cameraType = CameraType.FRONT;
  }

  Future<void> onToggleVideo() async {
    if (timer != null) timer.cancel();
    fullScreen = false;
    timer = onChangeFullScreenMode();
    videoEnabled = !videoEnabled;
    await rtcEngineClient.enableLocalVideo(videoEnabled);
  }

  Future<void> onToggleAudio() async {
    if (timer != null) timer.cancel();
    fullScreen = false;
    timer = onChangeFullScreenMode();
    audioEnabled = !audioEnabled;
    await rtcEngineClient.enableLocalAudio(audioEnabled);
  }

  Future<void> dispose() async {
    SystemChrome.setEnabledSystemUIOverlays(
      [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
    usersOnline.clear();
    try {
      if (rtcEngineClient != null) await rtcEngineClient.leaveChannel();
    } catch (e) {
      print("Erro ao deixar canal: $e");
    }
  }
}
