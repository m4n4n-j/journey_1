import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart'; //for Instagram icon
import 'package:screenshot/screenshot.dart'; // for taking screenshot
import 'package:path_provider/path_provider.dart'; // prerequisite of social_share
import 'package:social_share/social_share.dart'; // for directly sharing the screenshot to instagram story

// import 'package:esys_flutter_share/esys_flutter_share.dart'; // can be used to open standard share menu

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Removing the debug banner.

      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _imageFile;

  //Creating an instance of Screenshot Controller.
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Assignment"),
          ),

          // Adding the Image Container and the button in a Column.

          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Image Container

              Center(
                  child: Container(
                height: 200,
                width: 300,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/Journey.jpg'),
                    fit: BoxFit.contain,
                  ),
                ),
              )),

              //Button for sharing the screenshot.
              //Using a builder for showing snackbar.

              Builder(builder: (context) {
                return RaisedButton(
                  padding: EdgeInsets.all(15),
                  elevation: 10,
                  color: Colors.amberAccent[100],
                  onPressed: () async {
                    // Checking if Instagram app is installed on the device.

                    SocialShare.checkInstalledAppsForShare().then((data) {
                      if (data.toString().contains('instagram: false')) {
                        // Show a snackbar if Instagram is not installed.

                        final snackBar = SnackBar(
                          backgroundColor: Colors.red,
                          content:
                              Text('Install the Instagram app to continue.'),
                          action: SnackBarAction(
                            label: 'OK',
                            onPressed: () {},
                          ),
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }

                      //else Instagram is installed, Take a screenshot and share it to the story.

                      else {
                        _imageFile = null;
                        screenshotController
                            .capture(

                                // Delay is added to overcome a repaintboundary bug, https://github.com/flutter/flutter/issues/22308.

                                delay: Duration(milliseconds: 50),
                                pixelRatio: 2.0)
                            .then((File image) async {
                          setState(() {
                            _imageFile = image;
                          });

                          // Saving Image in application directory.

                          final directory =
                              (await getApplicationDocumentsDirectory()).path;
                          Uint8List pngBytes = _imageFile.readAsBytesSync();
                          File imgFile = new File('$directory/screenshot.png');
                          imgFile.writeAsBytes(pngBytes);
                          print("File Saved to Gallery");

                          // Sharing to instagram story.

                          SocialShare.shareInstagramStory(
                              '$directory/screenshot.png',
                              "#ffffff",
                              "#000000",
                              "https://dummy-link");
                        }).catchError((onError) {
                          print(onError);
                        });
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.instagram,
                        size: 32,
                        color: Colors.pinkAccent,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Share Screenshot to Instagram !",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                );
              })
            ],
          )),
    );
  }
}
