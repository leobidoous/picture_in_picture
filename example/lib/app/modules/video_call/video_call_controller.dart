import 'package:mobx/mobx.dart';
import 'package:flutter_modular/flutter_modular.dart';

part 'video_call_controller.g.dart';

@Injectable()
class VideoCallController = _VideoCallControllerBase with _$VideoCallController;

abstract class _VideoCallControllerBase with Store {
  @observable
  int value = 0;

  @action
  void increment() {
    value++;
  }
}
