import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:heyhelp/utils/routes.dart';
import 'package:velocity_x/velocity_x.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.canvasColor,
      child: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                VxArc(
                  height: 50,
                  child: Image.asset(
                    "assets/images/welcomeImage.png",
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                "Sign In"
                    .text
                    .bold
                    .color(context.accentColor)
                    .xl5
                    .make()
                    .pOnly(top: 50),
                SignInButton(
                  Buttons.Google,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(left: 30),
                  onPressed: () async {
                    print("here");
                    await signInWithGoogle();
                    print(FirebaseAuth.instance.currentUser!.uid);
                    Fluttertoast.showToast(
                        msg: "Logged in as " +
                            FirebaseAuth.instance.currentUser!.email
                                .toString());
                  },
                ).pOnly(top: 20, bottom: 10),
                SignInButton(
                  Buttons.FacebookNew,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(left: 30),
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Use Google");
                  },
                ).pOnly(bottom: 10),
                SignInButton(
                  Buttons.Twitter,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(left: 30),
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Use Google");
                  },
                ).pOnly(bottom: 10),
                SignInButton(
                  Buttons.Apple,
                  shape: StadiumBorder(),
                  padding: EdgeInsets.only(left: 30),
                  onPressed: () {
                    Fluttertoast.showToast(msg: "Use Google");
                  },
                ).pOnly(bottom: 10),
                // SignInButton(Buttons.Hotmail, onPressed: () async {
                //   await FirebaseAuth.instance.signOut();
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
