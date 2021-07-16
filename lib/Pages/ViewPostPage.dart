import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:heyhelp/utils/Pair.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

class ViewPost extends StatefulWidget {
  final String docRef;
  final String pod;
  final String title;
  final String para;
  final String date;
  final String author;
  final List<String> likes;
  final int views;
  final String attachmentURL;
  List<Pair<String, String>> comments;

  ViewPost(this.docRef, this.pod, this.title, this.para, this.date, this.author,
      this.likes, this.views, this.attachmentURL, this.comments);

  @override
  _ViewPostState createState() => _ViewPostState();
}

class _ViewPostState extends State<ViewPost> {
  final _formKey4 = GlobalKey<FormState>();
  bool addingComment = false;
  void launchURL(url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  fetchComments() async {
    widget.comments.clear();
    await FirebaseFirestore.instance
        .collection('pods')
        .doc(widget.pod)
        .collection('posts')
        .doc(widget.docRef)
        .collection('comments')
        .get()
        .then((value) => value.docs.forEach((element) {
              widget.comments
                  .add(Pair(element.data()['msg'], element.data()['author']));
            }));
  }

  addComment(msg) async {
    if (_formKey4.currentState!.validate()) {
      setState(() {
        commentController.text = '';
        addingComment = true;
      });
      await FirebaseFirestore.instance
          .collection('pods')
          .doc(widget.pod)
          .collection('posts')
          .doc(widget.docRef)
          .collection('comments')
          .add({'msg': msg, 'author': FirebaseAuth.instance.currentUser!.uid});
      await fetchComments();
      setState(() {
        addingComment = false;
      });
    }
  }

  Widget getcommentWidgets(
      List<Pair<String, String>> comments, BuildContext context) {
    return new Column(
      children: (comments
          .map(
            (item) => Card(
              margin: EdgeInsets.only(top: 4),
              child: Container(
                width: double.maxFinite,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(FirebaseAuth
                          .instance.currentUser!.photoURL
                          .toString()),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        item.first.text.make(),
                        item.second.text.caption(context).make()
                      ],
                    ).px12().expand(),
                  ],
                ).p12(),
              ),
            ),
          )
          .toList()),
    );
  }

  late TextEditingController commentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        title: "Post".text.xl4.color(context.theme.indicatorColor).bold.make(),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: context.theme.indicatorColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        actions: [],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero(
                // tag: Key(docRef.toString()),
                // child:

                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: context.canvasColor,
                      borderRadius: BorderRadius.circular(30)),
                  child: widget.title.text.xl2.bold
                      .color(context.theme.indicatorColor)
                      .center
                      .make()
                      .p16(),
                ),
                Divider(
                  thickness: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.calendarAlt,
                            color: context.theme.indicatorColor,
                            size: 15,
                          ).px12(),
                          widget.date.text
                              .color(context.theme.indicatorColor)
                              .make()
                        ],
                      ),
                    ),
                    ("@" + widget.author)
                        .text
                        .color(context.theme.indicatorColor)
                        .make()
                  ],
                ).pOnly(left: 16, top: 4, right: 16),
                Divider(
                  thickness: 10,
                ),
                Container(
                    padding: EdgeInsets.all(16),
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                        color: context.canvasColor,
                        borderRadius: BorderRadius.circular(30)),
                    child: MarkdownBody(
                      data: widget.para,
                      selectable: true,
                      onTapLink: (_, it, __) async {
                        launchURL(it);
                      },
                    )
                    // child: widget.para.text.xl.bold
                    //     .color(context.backgroundColor)
                    //     .justify
                    //     .make()
                    //     .p16(),
                    ),
                Divider(
                  thickness: 10,
                ),
                "Comments"
                    .text
                    .xl
                    .bold
                    .color(context.theme.indicatorColor)
                    .justify
                    .make()
                    .p16(),
                CupertinoFormSection(
                  header: "Write Comment".text.make(),
                  children: [
                    Form(
                      key: _formKey4,
                      child: CupertinoTextFormFieldRow(
                        controller: commentController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Can't post an empty comment";
                          }
                          return null;
                        },
                      ),
                    ),
                    addingComment
                        ? "Adding...".text.xl2.bold.make()
                        : GestureDetector(
                            child: "Send".text.xl2.bold.make(),
                            onTap: () async {
                              await addComment(commentController.text);
                            },
                          ),
                  ],
                ),
                getcommentWidgets(widget.comments, context),
                HeightBox(10),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: context.canvasColor,
        child: ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          buttonPadding: Vx.mH0,
          children: [
            LikeButton(
              size: 30,
              circleColor:
                  CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
              bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xff33b5e5),
                dotSecondaryColor: Color(0xff0099cc),
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  FontAwesomeIcons.solidHeart,
                  color: isLiked ? Colors.red : context.theme.indicatorColor,
                  size: 20,
                );
              },
              isLiked:
                  widget.likes.contains(FirebaseAuth.instance.currentUser!.uid),
              likeCount: widget.likes.length,
              likeCountPadding: EdgeInsets.only(left: 6),
              onTap: (isLiked) async {
                print(widget.likes);
                if (isLiked) {
                  widget.likes.remove(FirebaseAuth.instance.currentUser!.uid);
                  await FirebaseFirestore.instance
                      .collection("pods")
                      .doc(widget.pod)
                      .collection("posts")
                      .doc(widget.docRef)
                      .update({
                    'likes': FieldValue.arrayRemove(
                        [FirebaseAuth.instance.currentUser!.uid])
                  });
                } else {
                  widget.likes.add(FirebaseAuth.instance.currentUser!.uid);
                  await FirebaseFirestore.instance
                      .collection("pods")
                      .doc(widget.pod)
                      .collection("posts")
                      .doc(widget.docRef)
                      .update({
                    'likes': FieldValue.arrayUnion(
                        [FirebaseAuth.instance.currentUser!.uid])
                  });
                }
                setState(() {});
                return isLiked;
              },
            ),
            Row(
              children: [
                widget.views.text.gray400.make().px12(),
                Icon(
                  FontAwesomeIcons.eye,
                  color: context.theme.indicatorColor,
                  size: 20,
                ),
              ],
            ).px12(),
          ],
        ).p12(),
      ),
    );
  }
}
