import 'dart:io';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picture_in_picture_example/app/core/enums/enums.dart';

import 'video_call_controller.dart';

class VideoCallPage extends StatefulWidget {
  RtcEngine engine;
  final String title;

  VideoCallPage({
    Key key,
    this.title = "VideoCall",
    this.engine,
  }) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState
    extends ModularState<VideoCallPage, VideoCallController> {
  @override
  void initState() {
    controller.onCanInitCall();
    controller.context = context;
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        if (!controller.canInitCall) return _givePermissionsWidget();
        controller.initVideoCall("flutter", 123456);
        return _videoStackRender();
      },
    );
  }

  Widget _givePermissionsWidget() {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Observer(
              builder: (context) {
                if (controller.permissionStatus == PermissionStatus.denied ||
                    controller.permissionStatus ==
                        PermissionStatus.permanentlyDenied) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        onPressed: () async => await openAppSettings(),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text("Abrir configurações"),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        "* Permissões foram permanentemente negadas.\n"
                        "Acesse as configurações para concedê-las.",
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .color
                              .withOpacity(0.75),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  );
                }
                return Container();
              },
            ),
            Observer(builder: (context) {
              if (controller.hasAudioPermission) return Container();
              return FlatButton(
                onPressed: () async =>
                    await controller.onCheckAudioPermission(),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Permitir áudio"),
              );
            }),
            SizedBox(height: 10.0),
            Observer(builder: (context) {
              if (controller.hasVideoPermission) return Container();
              return FlatButton(
                onPressed: () async =>
                    await controller.onCheckVideoPermission(),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Permitir vídeo"),
              );
            }),
            SizedBox(height: 20.0),
            FlatButton(
              onPressed: () async => Navigator.pop(context),
              color: Colors.red,
              textColor: Colors.white,
              child: Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _videoStackRender() {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _primaryVideoScreen(),
          new AnimatedPadding(
            duration: Duration(milliseconds: 350),
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: controller.fullScreen ? 75.0 : 50.0,
              bottom: controller.fullScreen ? 150.0 : 50.0,
            ),
            child: new Align(
              alignment: controller.insideVideoAlignment,
              child: new Draggable(
                maxSimultaneousDrags: Platform.isIOS ? 0 : 1,
                child: _secondaryVideoScreen(),
                feedback: _secondaryVideoScreen(),
                childWhenDragging: Container(),
                onDragEnd: (DraggableDetails details) {
                  controller.onCalculateAlignment(context, details);
                },
              ),
            ),
          ),
          new Align(
            alignment: Alignment.bottomCenter,
            child: _toolbarCallOptions(),
          ),
        ],
      ),
    );
  }

  Widget _primaryVideoScreen() {
    return GestureDetector(
      onTap: () {
        if (controller.timer != null) controller.timer.cancel();
        controller.timer = controller.onChangeFullScreenMode();
      },
      child: Observer(
        builder: (context) {
          final bool _calling = controller.usersOnline.length == 1;
          if (_calling) return _renderLocalPreview();
          if (controller.switchVideos) return _renderLocalPreview();
          return _renderRemoteVideo();
        },
      ),
    );
  }

  Widget _secondaryVideoScreen() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => controller.switchVideos = !controller.switchVideos,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.2,
                maxWidth: MediaQuery.of(context).size.width * 0.2,
              ),
              child: Observer(
                builder: (context) {
                  final bool _calling = controller.usersOnline.length == 1;
                  if (_calling) return Container();
                  if (controller.switchVideos) {
                    return Container(
                      child: _renderRemoteVideo(),
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                    );
                  }
                  return Container(
                    color: Theme.of(context).cardColor.withOpacity(0.5),
                    child: _renderLocalPreview(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderLocalPreview() {
    return Observer(
      builder: (context) {
        if (controller.usersOnline.isEmpty) return Container();
        return Stack(
          fit: StackFit.expand,
          children: [
            new RtcLocalView.SurfaceView(),
            _statusVideoCall(),
          ],
        );
      },
    );
  }

  Widget _statusVideoCall() {
    return Observer(
      builder: (context) {
        if (!controller.switchVideos) {
          Widget _icon = Container();
          if (!controller.videoEnabled) {
            _icon = Icon(Icons.videocam_off_rounded, color: Colors.white);
          }
          if (!controller.audioEnabled) {
            _icon = Icon(Icons.mic_off_rounded, color: Colors.white);
          }
          if (!controller.videoEnabled && !controller.audioEnabled) {
            _icon = Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.videocam_off_rounded, color: Colors.white),
                Icon(Icons.mic_off_rounded, color: Colors.white),
              ],
            );
          }
          return Container(
            color: !controller.videoEnabled || !controller.audioEnabled
                ? Colors.black.withOpacity(0.65)
                : Colors.transparent,
            padding: EdgeInsets.all(20.0),
            child: Center(child: _icon),
          );
        }
        String _label = "";
        if (!controller.videoEnabled) {
          _label = "A câmera está desabilitada";
        }
        if (!controller.audioEnabled) {
          _label = "O áudio está desabilitado";
        }
        if (!controller.videoEnabled && !controller.audioEnabled) {
          _label = "A câmera e o áudio estão desabilitados";
        }
        return Container(
          color: !controller.videoEnabled || !controller.audioEnabled
              ? Colors.black.withOpacity(0.65)
              : Colors.transparent,
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              _label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _renderRemoteVideo() {
    return Observer(
      builder: (context) {
        if (controller.usersOnline.isEmpty) return Container();
        if (controller.usersOnline.length < 2) return Container();
        return new RtcRemoteView.SurfaceView(uid: controller.usersOnline.last);
      },
    );
  }

  Widget _toolbarCallOptions() {
    return Observer(
      builder: (context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 500),
          height: controller.fullScreen ? null : 0.0,
          constraints: BoxConstraints(maxHeight: 500.0),
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          curve: Curves.decelerate,
          child: Card(
            elevation: 0.0,
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: EdgeInsets.all(5.0),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          iconSize: 40.0,
                          icon: Icon(Icons.call_end, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade900.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.all(5.0),
                        child: IconButton(
                          onPressed: () async {
                            await controller.onToggleAudio();
                          },
                          iconSize: 30.0,
                          color: Colors.white,
                          icon: Icon(
                            controller.audioEnabled
                                ? Icons.mic_rounded
                                : Icons.mic_off_rounded,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade900.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.all(5.0),
                        child: IconButton(
                          onPressed: () async {
                            await controller.onToggleVideo();
                          },
                          iconSize: 30.0,
                          color: Colors.white,
                          icon: Icon(
                            controller.videoEnabled
                                ? Icons.videocam_rounded
                                : Icons.videocam_off_rounded,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade900.withOpacity(0.2),
                        ),
                        padding: EdgeInsets.all(5.0),
                        child: IconButton(
                          onPressed: () async {
                            await controller.onChangeCameraType();
                          },
                          iconSize: 30.0,
                          color: Colors.white,
                          icon: Icon(
                            controller.cameraType == CameraType.FRONT
                                ? Icons.camera_front_rounded
                                : Icons.camera_rear_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
