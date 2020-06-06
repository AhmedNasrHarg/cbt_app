import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/localization/localization_constants.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/community.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/learn_page.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/chillzone.dart';
import 'package:fluttershare/pages/sheets_entery_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection("users");
final postRef = Firestore.instance.collection("posts");
final commentRef = Firestore.instance.collection("comments");
final groupRef = Firestore.instance.collection("groups");
final chatRef = Firestore.instance.collection("chats");
final sheetsRef = Firestore.instance.collection("sheets");
final albumRef = Firestore.instance.collection("album");
final topicRef = Firestore.instance.collection("topic");
final chillRef = Firestore.instance.collection("chill_zone");
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    // Detect's when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handelSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
    // Reauthenticate user when app is opened
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handelSignIn(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });
  }

  handelSignIn(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    // 1) check if user exists in users collection in database (according to their id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();

    // 2) if the user dosn't exist, then we want to take them to the create account page
    if (!doc.exists) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

      // 3) get username from create account, use it to make new user document in users collection

      userRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": DateTime.now(),
        "isAdmin": false,
      });
      doc = await userRef.document(user.id).get();
    }
    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
    setState(() {
      pageIndex = 0;
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Profile(
            profileId: currentUser.id,
          ),
          LearnPage(),
          ChillZone(),
          EnterySheets(),
          Community(),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              title: Text(getTranslated(context, "profile"))),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              title: Text(getTranslated(context, "learn"))),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.wb_sunny,
                size: 35.0,
              ),
              title: Text(getTranslated(context, "chill_zone"))),
          BottomNavigationBarItem(
              icon: Icon(Icons.note),
              title: Text(getTranslated(context, "sheets"))),
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              title: Text(getTranslated(context, "community"))),
        ],
      ),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  Widget buildUnAuthScreen() {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                Theme.of(context).accentColor,
                Theme.of(context).primaryColor
              ])),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                getTranslated(context, "project_name"),
                style: TextStyle(
                    fontFamily:
                        Localizations.localeOf(context).languageCode == "ar"
                            ? "Lemonada"
                            : "Signatra",
                    fontSize: 90.0,
                    color: Colors.white),
              ),
              GestureDetector(
                onTap: login,
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  )),
                ),
              )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
