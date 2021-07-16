import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:heyhelp/utils/routes.dart';
import 'package:velocity_x/velocity_x.dart';

class NewUser extends StatefulWidget {
  @override
  _NewUserState createState() => _NewUserState();
}

class _NewUserState extends State<NewUser> {
  late TextEditingController aboutController;
  late TextEditingController usrNameController;
  late String podName;
  final _formKey2 = GlobalKey<FormState>();

  int selectedValue = 0;

  initState() {
    usrNameController = new TextEditingController();
    aboutController = new TextEditingController();
    getPods();
    super.initState();
  }

  bool forAnimation = false;
  List<Widget> pods = [Text("Select")];
  List<String> podsString = ["Select"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        padding: Vx.m32,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "Take A Moment"
                    .text
                    .color(context.accentColor)
                    .xl4
                    .bold
                    .make()
                    .py12(),
                "Since you are here for the first time."
                    .text
                    .color(context.primaryColor)
                    .xl2
                    .make(),
                CupertinoFormSection(
                  backgroundColor: Colors.transparent,
                  header: "Your Info".text.make(),
                  children: [
                    CupertinoFormRow(
                      //padding: EdgeInsets.only(left: 0),
                      child: CupertinoTextFormFieldRow(
                        controller: usrNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username can't be empty";
                          }
                          return null;
                        },
                        placeholder: "Username",
                        padding: EdgeInsets.only(left: 0),
                      ),
                    ),
                    CupertinoFormRow(
                      //padding: EdgeInsets.only(left: 0),
                      child: CupertinoTextFormFieldRow(
                        controller: aboutController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "About can't be empty";
                          }
                          return null;
                        },
                        placeholder: "About",
                        maxLines: 3,
                        maxLength: 100,
                        // prefix: "Username".text.make(),
                        padding: EdgeInsets.only(left: 0),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: showPicker,
                  child: CupertinoFormSection(
                    backgroundColor: context.canvasColor,
                    header: "Pod".text.make(),
                    children: [
                      CupertinoTextFormFieldRow(
                        decoration: BoxDecoration(color: Colors.white),
                        readOnly: true,
                        prefix: pods[selectedValue],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Material(
                      color: context.theme.buttonColor,
                      borderRadius:
                          BorderRadius.circular(forAnimation ? 50 : 50),
                      child: selectedValue != 0
                          ? InkWell(
                              onTap: () => moveToHome(),
                              child: AnimatedContainer(
                                duration: Duration(seconds: 1),
                                alignment: Alignment.center,
                                child: forAnimation
                                    ? Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      )
                                    : Icon(
                                        CupertinoIcons.chevron_right,
                                        size: 40,
                                        color: Colors.white,
                                      ),
                                width: forAnimation ? 50 : 50,
                                height: 50,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                10.heightBox,
              ],
            ),
          ),
        ),
      ),
    ));
  }

  showPicker() {
    showModalBottomSheet(
        elevation: 10,
        context: context,
        builder: (BuildContext context) {
          return CupertinoPicker(
            backgroundColor: Colors.white,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedValue = value;
              });
            },
            itemExtent: 32.0,
            children: pods,
          );
        });
  }

  getPods() async {
    await FirebaseFirestore.instance
        .collection("pods")
        .orderBy("name")
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((queryDocumentSnapshot) {
        pods.add(Text(queryDocumentSnapshot.data()['name']));
        podsString.add(queryDocumentSnapshot.data()['name']);
        print(queryDocumentSnapshot.data()['name']);
      });
    });
    print(pods);
  }

  moveToHome() async {
    print(pods);
    print(podsString);
    if (_formKey2.currentState!.validate()) {
      setState(() {
        forAnimation = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "userName": usrNameController.text,
        "podName": podsString[selectedValue],
        "about": aboutController.text
      }).then((value) {
        Fluttertoast.showToast(msg: "Hey " + usrNameController.text);
        Navigator.pushReplacementNamed(context, MyRoutes.homeScreenShower);
      });
    }
  }
}
