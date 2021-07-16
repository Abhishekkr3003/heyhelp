import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:heyhelp/Pages/NewUser.dart';

import 'HomePage.dart';
import 'drawerPage.dart';

class HomeScreenViewer extends StatefulWidget {
  const HomeScreenViewer({Key? key}) : super(key: key);

  @override
  _HomeScreenViewerState createState() => _HomeScreenViewerState();
}

class _HomeScreenViewerState extends State<HomeScreenViewer> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
          bottom: false,
          child: Stack(
            children: [DrawerScreen(), HomePage()],
          )),
    );
  }
}
