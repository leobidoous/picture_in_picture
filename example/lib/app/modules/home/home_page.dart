import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:picture_in_picture/src/picture_in_picture.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title = "Home"}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ModularState<HomePage, HomeController> {
  //use 'controller' variable to access controller
  OverlayState _overlayState;
  OverlayEntry _detailsOverlayEntry;

  @override
  void initState() {
    _overlayState = Overlay.of(context);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return PictureInPicture(
      builder: (context, isFloating) {
        return Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('This is the screen that will float!'),
              MaterialButton(
                child: Text('Start floating'),
                color: Colors.red,
                onPressed: () {
                  PictureInPicture.of(context).startFloating(Container());
                },
              ),
              MaterialButton(
                child: Text('close'),
                color: Colors.red,
                onPressed: () {
                  _detailsOverlayEntry.remove();
                  // Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Start"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FlatButton(
            onPressed: () {
              _detailsOverlayEntry = OverlayEntry(builder: (context) {
                return PictureInPicture(
                  builder: (context, isFloating) {
                    return Scaffold(
                      body: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('This is the screen that will float!'),
                          MaterialButton(
                            child: Text('Start floating'),
                            color: Colors.red,
                            onPressed: () {
                              PictureInPicture.of(context).startFloating(Container());
                            },
                          ),
                          MaterialButton(
                            child: Text('close'),
                            color: Colors.red,
                            onPressed: () {
                              _detailsOverlayEntry.remove();
                              // Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              });
              _overlayState.insert(_detailsOverlayEntry);
            },
            color: Theme.of(context).primaryColor,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Text("open pip"),
          ),
          SizedBox(height: 100.0),
          FlatButton(
            onPressed: () {
              // Modular.to.pushNamed("/home");
              Navigator.of(context).pushNamed("/second");
              print("aasdasd");
            },
            color: Theme.of(context).primaryColor,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Text("Go to home"),
          ),
          SizedBox(height: 100.0),
          FlatButton(
            onPressed: () {
              // Modular.to.pushNamed("/home");
              Navigator.of(context).pushNamed("/video_call");
              print("aasdasd");
            },
            color: Theme.of(context).primaryColor,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Text("Go to video call"),
          ),
        ],
      ),
    );
  }
}
