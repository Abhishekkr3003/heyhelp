import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

late TextEditingController paraController;

class AddPost extends StatefulWidget {
  const AddPost({Key? key}) : super(key: key);

  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  late TextEditingController titleController;

  bool viewMarkDown = false;

  final _formKey3 = GlobalKey<FormState>();
  initState() {
    titleController = new TextEditingController();
    paraController = new TextEditingController();
    super.initState();
  }

  late File file;
  late String fileName = '';

  selectAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = File(result.files.single.path.toString());
      fileName = result.files.first.name;
      print('${file.readAsBytesSync()}');
      print(fileName);
      setState(() {
        haveAttachment = true;
      });
    } else {
      setState(() {
        haveAttachment = false;
      });
    }
  }

  String downloadURL = "";
  uploadFile() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 20; i++) {
      randomName += rng.nextInt(100).toString();
    }
    fileName = randomName + fileName;
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('UserData/$fileName')
          .putFile(file);
      downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('UserData/$fileName')
          .getDownloadURL();
      print(downloadURL);
    } catch (e) {
      print(e);
    }
  }

  bool adding = false;
  bool haveAttachment = false;
  uploadPost() async {
    if (_formKey3.currentState!.validate()) {
      setState(() {
        adding = true;
      });

      if (haveAttachment) {
        print("here");
        await uploadFile();
      }
      print(paraController.text);
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      final String formatted = formatter.format(now);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        await FirebaseFirestore.instance
            .collection("pods")
            .doc(value.data()!['podName'])
            .collection('posts')
            .add(
          {
            "title": titleController.text,
            "para": paraController.text,
            "author": FirebaseAuth.instance.currentUser!.uid,
            "attachmentURL": downloadURL,
            "likes": [],
            "views": 0,
            "date": formatted,
          },
        );
      });
      Navigator.pop(context);
      setState(() {
        adding = false;
      });
    }
  }

  _showDialog(BuildContext context) {
    CupertinoAlertDialog alert = CupertinoAlertDialog(
      title: Text('Info'),
      content: Text('This editior is Markdown enabled.'),
      actions: [
        CupertinoDialogAction(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          child: Text('Know More'),
          onPressed: () {
            launchURL(
                "https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown");
          },
        )
      ],
    );

    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          color: context.theme.indicatorColor,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: "Write a Post".text.color(context.theme.indicatorColor).xl3.bold.make(),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.infoCircle),
            color: context.theme.indicatorColor,
            onPressed: () {
              _showDialog(context);
            },
          ).px4(),
          CupertinoSwitch(
            activeColor: context.canvasColor,
            value: viewMarkDown,
            onChanged: (value) {
              setState(() {
                viewMarkDown = value;
              });
            },
          )
        ],
      ),
      body: SafeArea(
        child: adding
            ? Image.asset(
                "assets/gifs/loading.gif",
                height: 550,
                width: double.maxFinite,
              )
            : Container(
                padding: Vx.m16,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CupertinoFormSection(
                          backgroundColor: Colors.transparent,
                          header: "Title".text.make(),
                          children: [
                            CupertinoFormRow(
                              //padding: EdgeInsets.only(left: 0),
                              child: CupertinoTextFormFieldRow(
                                controller: titleController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Title can't be empty";
                                  }
                                  return null;
                                },
                                padding: EdgeInsets.only(left: 0),
                              ),
                            ),
                          ],
                        ),
                        viewMarkDown
                            ? MarkdownBody(
                                // shrinkWrap: true,
                                data: paraController.text,
                                selectable: true,
                                onTapLink: (_, it, __) async {
                                  launchURL(it);
                                },
                              )
                            : postBodyTextField(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            haveAttachment
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.red,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            child: fileName.text
                                                .color(context.canvasColor)
                                                .makeCentered(),
                                            onTap: () async {
                                              setState(() {
                                                haveAttachment = false;
                                                fileName = '';
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: context.cardColor,
                                        child: Center(
                                          child: GestureDetector(
                                            child: "Add Attachment"
                                                .text
                                                .xl2
                                                .bold
                                                .color(context.theme.indicatorColor)
                                                .make(),
                                            onTap: () async {
                                              await selectAttachment();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width,
                                    color: context.cardColor,
                                    child: Center(
                                      child: GestureDetector(
                                        child: "Post"
                                            .text
                                            .xl2
                                            .bold
                                            .color(context.theme.indicatorColor)
                                            .make(),
                                        onTap: () async {
                                          await uploadPost();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Widget postBodyTextField() {
    return LayoutBuilder(builder: (context, size) {
      TextSpan text = new TextSpan(
        text: paraController.text,
      );

      TextPainter tp = new TextPainter(
        text: text,
        textDirection: ui.TextDirection.ltr,
        textAlign: TextAlign.left,
      );
      tp.layout(maxWidth: size.maxWidth);

      int lines = (tp.size.height / tp.preferredLineHeight).ceil();
      int maxLines = 20;

      return CupertinoFormSection(
          header: "Start writing here".text.make(),
          backgroundColor: context.canvasColor,
          children: [
            CupertinoTextFormFieldRow(
              controller: paraController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field can't be empty";
                }
                return null;
              },
              maxLines: lines > maxLines ? null : maxLines,
              textInputAction: TextInputAction.newline,
            ),
          ]).pOnly(bottom: 16);
    });
  }
}
