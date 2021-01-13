import 'package:flutter_modular/flutter_modular.dart';

import 'second_controller.dart';
import 'second_page.dart';

class SecondModule extends ChildModule {
  @override
  List<Bind> get binds => [
        Bind((i) => SecondController()),
      ];

  @override
  List<ModularRouter> get routers => [
        ModularRouter(Modular.initialRoute, child: (_, args) => SecondPage()),
      ];

  static Inject get to => Inject<SecondModule>.of();
}
