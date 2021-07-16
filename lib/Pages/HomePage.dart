import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heyhelp/utils/Pair.dart';
import 'package:velocity_x/velocity_x.dart';

import 'ViewPostPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double xOffset = 0;
  double yOffset = 0;
  double scaleFactor = 1;

  bool isDrawerOpen = false;

  final List<String> titles = [];
  final List<String> authors = [];
  final List<int> views = [];
  final List<String> dates = [];
  final List<List<String>> likes = [];
  final List<String> paras = [];
  final List<String> attachmentlinks = [];
  final List<String> docRef = [];
  late String pod = '';
  bool addingData = true;

  List<Pair<String, String>> comments = [];
  fetchComments(String pod, String docRef) async {
    comments.clear();
    await FirebaseFirestore.instance
        .collection('pods')
        .doc(pod)
        .collection('posts')
        .doc(docRef)
        .collection('comments')
        .get()
        .then((value) => value.docs.forEach((element) {
              comments
                  .add(Pair(element.data()['msg'], element.data()['author']));
            }));
  }

  loadData() async {
    setState(() {
      addingData = true;
    });
    titles.clear();
    authors.clear();
    views.clear();
    likes.clear();
    dates.clear();
    paras.clear();
    attachmentlinks.clear();
    docRef.clear();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      pod = value.data()!['podName'];
      await FirebaseFirestore.instance
          .collection("pods")
          .doc(value.data()!['podName'])
          .collection('posts')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          docRef.add(element.id);
          titles.add(element.data()['title']);
          authors.add(element.data()['author']);
          // print(element.data()['views']);
          print(element.data()['views']);
          views.add(element.data()['views']);
          dates.add(element.data()['date']);
          likes.add(List.from(element.data()['likes']));
          paras.add(element.data()['para']);
          attachmentlinks.add(element.data()['attachmentURL']);
        });
      });
      print(value.data()!['podName']);
    });
    print(titles);
    print(authors);
    print(dates);
    print(views);
    print(likes);
    setState(() {
      addingData = false;
    });
  }

  @override
  initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var initial;
    var distance;
    return GestureDetector(
      onPanStart: (DragStartDetails details) {
        initial = details.globalPosition.dx;
      },
      onPanUpdate: (DragUpdateDetails details) {
        distance = details.globalPosition.dx - initial;
      },
      onPanEnd: (DragEndDetails details) {
        initial = 0.0;
        print(distance);
        if (distance < 0)
          setState(() {
            xOffset = -100;
            yOffset = 150;
            scaleFactor = 0.7;
            isDrawerOpen = true;
          });
        else {
          setState(() {
            xOffset = 0;
            yOffset = 0;
            scaleFactor = 1;
            isDrawerOpen = false;
          });
        }
      },
      child: AnimatedContainer(
        //height: double.infinity,
        transform: Matrix4.translationValues(xOffset, yOffset, 0)
          ..scale(scaleFactor)
          ..rotateY(isDrawerOpen ? -0.5 : 0),
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
            color: context.canvasColor,
            borderRadius: BorderRadius.circular(isDrawerOpen ? 60 : 0.0)),

        //padding: EdgeInsets.only(left: 16, top: 16, right: 16),
        //color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                "HeyHelp".text.xl5.color(context.accentColor).bold.make(),
                Row(
                  children: [
                    IconButton(
                        onPressed: () async {
                          await loadData();
                        },
                        icon: Icon(FontAwesomeIcons.syncAlt)),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: isDrawerOpen
                          ? IconButton(
                              icon: Icon(FontAwesomeIcons.chevronCircleRight),
                              onPressed: () {
                                setState(() {
                                  xOffset = 0;
                                  yOffset = 0;
                                  scaleFactor = 1;
                                  isDrawerOpen = false;
                                });
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                FontAwesomeIcons.ioxhost,
                                size: 40,
                              ),
                              onPressed: () {
                                setState(
                                  () {
                                    xOffset = -100;
                                    yOffset = 150;
                                    scaleFactor = 0.7;
                                    isDrawerOpen = true;
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                )
              ],
            ).pOnly(
              left: 20,
              top: 10,
              right: 20,
            ),
            CupertinoSearchTextField(
              style: TextStyle(
                color: context.primaryColor,
              ),
              onChanged: (value) {
                // SearchMutation(value);
              },
            ).pOnly(top: 8, left: 20, right: 20, bottom: 8),
            "Trending"
                .text
                .color(context.primaryColor)
                .xl2
                .bold
                .make()
                .pOnly(left: 22, right: 16),
            10.heightBox,
            addingData
                ? Center(
                    child: CircularProgressIndicator(
                      color: context.accentColor,
                    ),
                  ).expand()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      print(titles);
                      print(index);
                      // return titles[index].text.make();
                      return GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                          padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                          // elevation: double.maxFinite,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Divider(
                              //   indent: 50,
                              //   endIndent: 50,
                              //   thickness: 5,
                              // ),
                              (titles[index])
                                  .text
                                  .bold
                                  .center
                                  .xl
                                  .makeCentered(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  authors[index].text.caption(context).make(),
                                  dates[index].text.caption(context).make(),
                                  Row(
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.eye,
                                        size: 10,
                                      ),
                                      views[index]
                                          .text
                                          .caption(context)
                                          .make()
                                          .pOnly(left: 6),
                                    ],
                                  ).p12()
                                ],
                              ),
                              // Divider(
                              //   indent: 50,
                              //   endIndent: 50,
                              //   thickness: 5,
                              // ),
                            ],
                          ),
                        ),
                        onTap: () async {
                          await fetchComments(pod, docRef[index]);
                          if (authors[index] !=
                              FirebaseAuth.instance.currentUser!.uid) {
                            views[index] += 1;
                            await FirebaseFirestore.instance
                                .collection("pods")
                                .doc(pod)
                                .collection("posts")
                                .doc(docRef[index])
                                .update({'views': FieldValue.increment(1)});
                          }

                          print(comments);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewPost(
                                  docRef[index],
                                  pod,
                                  titles[index],
                                  paras[index],
                                  dates[index],
                                  authors[index],
                                  likes[index],
                                  views[index],
                                  attachmentlinks[index],
                                  comments),
                            ),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ).expand(),
          ],
        ),
      ),
    );
  }
}
