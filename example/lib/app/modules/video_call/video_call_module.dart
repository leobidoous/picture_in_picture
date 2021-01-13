import 'package:flutter_modular/flutter_modular.dart';

import 'video_call_controller.dart';
import 'video_call_page.dart';

class VideoCallModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => VideoCallController()),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute,
            child: (_, args) => VideoCallPage()),
      ];

  static Inject get to => Inject<VideoCallModule>.of();
}
