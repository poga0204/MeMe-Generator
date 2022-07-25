import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MemeGenerator(),
    );
  }
}

class MemeGenerator extends StatefulWidget {
  @override
  _MemeGeneratorState createState() => _MemeGeneratorState();
}

class _MemeGeneratorState extends State<MemeGenerator> {
  String first = '';
  String second = '';
  bool showbutton = false;
  bool secondbutton = false;
  var initial;
  String url = '';
  final GlobalKey globalKey = new GlobalKey();
  final GlobalKey global = new GlobalKey();

  Future<String> getData() async {
    var response = await get(Uri.parse('https://api.imgflip.com/get_memes'));
    String data = response.body;
    if (response.statusCode == 200) {
      // new Directory('storage/emulated/0/' + 'MemeGenerator')
      //     .create(recursive: true);
      print(jsonDecode(data)['data']['memes'][Random().nextInt(100)]['url']);
      return jsonDecode(data)['data']['memes'][Random().nextInt(100)]['url'];
    }
    return '404';
  }

  File? image;
  File? _imageFile;
  File? _Fileimage;
  Random rng = new Random();
  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    try {
      if (image == null) {
        return;
      }
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;

        new Directory('storage/emulated/0/' + 'MemeGenerator')
            .create(recursive: true);
      });
    } catch (e) {
      print("Image cannot be loaded");
    }
  }

  Future getImageCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    try {
      if (image == null) {
        return;
      }
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
      });
      new Directory('storage/emulated/0/' + 'MemeGenerator')
          .create(recursive: true);
    } catch (e) {
      print("Image cannot be loaded");
    }
  }

  takeScreenshot() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    print(pngBytes);
    print('#######');
    File imgFile = File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _imageFile = imgFile;
    });
    save(_imageFile!);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);
  }

  takeUrl() async {
    RenderRepaintBoundary boundary =
        global.currentContext?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    print(pngBytes);
    print('#######');
    File imgFile = File('$directory/screenshot${rng.nextInt(200)}.png');
    setState(() {
      _Fileimage = imgFile;
    });
    save(_Fileimage!);
    //saveFileLocal();
    imgFile.writeAsBytes(pngBytes);
  }

  save(File file) async {
    await _askPermission();
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(await file.readAsBytes()));
    print(result);
    print("***********8888");
  }

  _askPermission() async {
    Map<Permission, PermissionStatus> statuses =
        await [Permission.photos, Permission.storage].request();
    print(statuses[Permission.photos]);
    print(statuses[Permission.storage]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal[400],
        title: const Text(
          'MeMe Generator',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: TextField(
                    onChanged: (value) {
                      first = value;
                    },
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      hintText: 'First',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                  width: 10,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: TextField(
                    onChanged: (value) {
                      second = value;
                    },
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      hintText: 'Last',
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                showbutton
                    ? RepaintBoundary(
                        key: global,
                        child: Container(
                          height: 450,
                          width: 800,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  url,
                                )),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      first,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 350,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    second,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                secondbutton
                    ? RepaintBoundary(
                        key: globalKey,
                        child: Container(
                          height: 450,
                          width: 800,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(
                                  image!,
                                )),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                fit: FlexFit.loose,
                                flex: 1,
                                child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      first,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 25),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 350,
                              ),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    second,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        height: 0,
                      ),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.teal[400]),
                    ),
                    onPressed: () async {
                      url = await getData();
                      setState(() {
                        print(url);
                        showbutton = true;
                        secondbutton = false;
                      });
                    },
                    child: const Text(
                      'Get Meme',
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.teal[400]),
                    ),
                    onPressed: () async {
                      await getImage();
                      setState(() {
                        secondbutton = true;
                        showbutton = false;
                      });
                    },
                    child: const Text(
                      'Image from gallery',
                    )),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.teal[400]),
                    ),
                    onPressed: () async {
                      await getImageCamera();
                      setState(() {
                        secondbutton = true;
                        showbutton = false;
                      });
                    },
                    child: const Text(
                      'Image from camera',
                    )),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.teal[400]),
                  ),
                  onPressed: () {
                    if (secondbutton == true) {
                      takeScreenshot();
                    } else if (showbutton == true) {
                      takeUrl();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
