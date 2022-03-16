import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../utils/custom_dialogs.dart';

class CampaignsPage extends StatefulWidget {
  const CampaignsPage({Key? key}) : super(key: key);

  @override
  _CampaignsPageState createState() => _CampaignsPageState();
}

class _CampaignsPageState extends State<CampaignsPage> {
  final ImagePicker _picker = ImagePicker();
  late User currentUser;
  final formkey = GlobalKey<FormState>();
  late String _text, _name;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  bool isLoggedIn() {
    if (FirebaseAuth.instance.currentUser! != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> addData(_user) async {
    if (isLoggedIn()) {
      FirebaseFirestore.instance
          .collection('Campaign Details')
          .doc()
          .set(_user)
          .catchError((e) {
        print(e);
      });
    } else {
      print('You need to be logged In');
    }
  }

  void _loadCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  Future<Future> dialogTrigger(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Post Submitted'),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  formkey.currentState!.reset();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CampaignsPage()));
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color.fromARGB(1000, 221, 46, 68),
                ),
              ),
            ],
          );
        });
  }

  late XFile _image;
  String _path = "";

  Future getImage(bool isCamera) async {
    XFile? image;
    String path;
    if (isCamera) {
      image = await _picker.pickImage(source: ImageSource.camera);
      path = image!.path;
    } else {
      image = await _picker.pickImage(source: ImageSource.gallery);
      path = image!.path;
    }
    setState(() {
      _image = image!;
      _path = path;
    });
  }

  Future<String> uploadImage() async {
    String downloadUrl = "";
    User user = FirebaseAuth.instance.currentUser!;
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('campaignposters/${user.uid}/$_name.jpg');
    UploadTask uploadTask = storageReference.putFile(File(_path));

    await uploadTask.then((res) async {
      downloadUrl = await res.ref.getDownloadURL();
    });

    return downloadUrl;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      systemNavigationBarColor: Colors.black, //bottom bar color
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Campaigns",
          style: TextStyle(
            fontSize: 60.0,
            fontFamily: "SouthernAire",
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            FontAwesomeIcons.reply,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(40.0), topRight: Radius.circular(40.0)),
        child: Container(
          height: 800.0,
          width: double.infinity,
          color: Colors.white,
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton(
            backgroundColor: const Color.fromARGB(1000, 221, 46, 68),
            child: const Icon(
              FontAwesomeIcons.pen,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Make a post about your campaign"),
                  content: Form(
                    key: formkey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Organisation name',
                                icon: Icon(
                                  FontAwesomeIcons.user,
                                  color: Color.fromARGB(1000, 221, 46, 68),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "This field can't be empty"
                                  : null,
                              onSaved: (value) => _name = value!,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                hintText: 'Wite something here',
                                icon: Icon(
                                  FontAwesomeIcons.pen,
                                  color: Color.fromARGB(1000, 221, 46, 68),
                                ),
                              ),
                              validator: (value) => value!.isEmpty
                                  ? "This field can't be empty"
                                  : null,
                              onSaved: (value) => _text = value!,
                              keyboardType: TextInputType.multiline,
                              maxLength: 120,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              IconButton(
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () {
                                    getImage(true);
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.filter),
                                  onPressed: () {
                                    getImage(false);
                                  }),
                            ],
                          ),
                          _path.isEmpty
                              ? const SizedBox()
                              : Image.file(
                                  File(_path),
                                  height: 150.0,
                                  width: 150.0,
                                ),
                        ],
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    RaisedButton(
                      color: const Color.fromARGB(1000, 221, 46, 68),
                      onPressed: () async {
                        if (!formkey.currentState!.validate()) return;
                        formkey.currentState!.save();
                        CustomDialogs.progressDialog(
                            context: context, message: 'Uploading');
                        var url = await uploadImage();
                        Navigator.of(context).pop();
                        final Map<String, dynamic> campaignDetails = {
                          'uid': currentUser.uid,
                          'content': _text,
                          'image': url,
                          'name': _name,
                        };
                        addData(campaignDetails).then((result) {
                          dialogTrigger(context);
                        }).catchError((e) {
                          print(e);
                        });
                      },
                      child: const Text(
                        'POST',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
