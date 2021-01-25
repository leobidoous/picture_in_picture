import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:picture_in_picture/classes/picture_in_picture.dart';
import 'package:picture_in_picture/source/pip_mode.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, HomeController> {
  @override
  void initState() {
    controller.pipMode = PIPMode(context: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("HOME"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlatButton(
            onPressed: () {
              controller.pipMode.createPIP(_pictureInPicture());
            },
            color: Theme.of(context).primaryColor,
            child: Text("Abrir PIP Mode"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.pushNamed(context, "/second");
            },
            color: Theme.of(context).primaryColor,
            child: Text("Segunda página"),
          ),
        ],
      ),
    );
  }

  PictureInPicture _pictureInPicture() {
    return PictureInPicture(
      builder: (context, isFloating) {
        return Theme(
          data: ThemeData(primaryColor: Colors.red),
          child: Scaffold(
            appBar: AppBar(
              title: Text("PIP MODE"),
            ),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FlatButton(
                  onPressed: () {
                    PictureInPicture.of(context).startFloating();
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text("Ativar PIP Mode"),
                ),
                FlatButton(
                  onPressed: () {
                    controller.pipMode.closePIP();
                  },
                  color: Theme.of(context).primaryColor,
                  child: Text("Fechar PIP Mode"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
