import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttershare/classes/learn_bar.dart';
import 'package:fluttershare/classes/sheet.dart';
import 'package:fluttershare/classes/sheets_bar.dart';
import 'package:fluttershare/pages/flexible_sheets_bar.dart';
import 'package:fluttershare/widgets/sheet_chat.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:fluttershare/pages/home.dart';

class EnterySheets extends StatefulWidget {
  EnterySheets({Key key}) : super(key: key);
  @override
  _EnterySheetsState createState() => _EnterySheetsState();
}

class _EnterySheetsState extends State<EnterySheets> {
  List<Sheet> sheets = [];
  List<String>sheetImages=[];
  int lastDone;
  @override
  void initState() {
    super.initState();
    getSheets();
  }
//getAll()
//async {
//  await getSheets();
//  if(!sheets.isEmpty) {
//    await setImages();
//  }
//}
  getSheets() async {
    QuerySnapshot snapshot = await sheetsRef
        .orderBy("sheetNumber", descending: false)
        .getDocuments();
    snapshot.documents.forEach((DocumentSnapshot doc) async {
      Sheet sheet = Sheet.fromDocument(doc);
      DocumentSnapshot completeDoc = await userRef
          .document(currentUser.id)
          .collection("completedSheets")
          .document("${sheet.sheetIdName}Log")
          .get();
      if (completeDoc.exists) {
        sheet.done = completeDoc["isDone"];
        sheet.sheetImage="assets/images/reward.png";
        lastDone=sheet.sheetNumber;
      } else {
        sheet.done = false;

        if(sheet.sheetNumber==1||(sheet.sheetNumber!=1&&lastDone!=null&&sheet.sheetNumber==(lastDone+1)))
          {
            sheet.sheetImage="assets/images/flower.png";
          }
        else{
          sheet.sheetImage="assets/images/lock.png";
        }
      }
      sheets.add(sheet);
      setState(() {
        sheets = sheets;
      });
    });

  }
//  setImages()
//  {
//    print("In imagessss");
//    print("length of sheets ${sheets.length}");
//    for(int i=0;i<sheets.length;i++)
//      {
//        sheetImages.add("assets/images/flower.png");
//
//        if(sheets[i].done)
//          {
//            sheetImages[i]="assets/images/reward.png";
//          }
//        else if(i!=0&&sheets[i-1].done==false)
//          {
//            sheetImages[i]="assets/images/lock.png";
//          }
//        setState(() {
//          sheetImages=sheetImages;
//        });
//
//      }
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: SheetsAppBar(),
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(background: FlexibleSheetsBar()),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return (Ink(
                  color: Color(sheets[index].sheetColor),
                  child: ListTile(
                     leading: Container(
                       height: 35.0,
                       width: 35.0,
                       child: Image.asset(
                          sheets[index].sheetImage),
                     ),
                    title: Center(
                      child: Text(
                          "${sheets[index].sheetTitle}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              decorationThickness: 2.85)),
                    ),
                    onTap: () {
                    if(lastDone!=null&&sheets[index].sheetNumber==lastDone+1||sheets[index].sheetNumber==1)
                     {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyHomePage(title: sheets[index].sheetIdName,sheetName: sheets[index].sheetTitle,)),
                      );
                    }
                         else {
                           Alert(
                               context: context,
                               title:
                                   "لا يمكنك فتح تلك الصفحة دون اكمال السابقة",
                               content: Column(
                                 children: <Widget>[
                                   Lottie.asset(
                                     'assets/animations/cant.json',
                                     width: 300,
                                     height: 300,
                                     fit: BoxFit.fill,
                                   ),
                                 ],
                               ),
                               buttons: [
                                 DialogButton(
                                   onPressed: () => Navigator.pop(context),
                                   child: Text("حسنا"),
                                 )
                               ]).show();
                         }
                      // } else {
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => SheetDetails(
                      //                 index: index,
                      //               )));
                      // }
                    },
                  ),
                  height: 100,
                ));
                // return Divider(height: 0, color: Colors.grey);
              },
              childCount: sheets.length,
            ),
          ),
        ],
      ),
    );
  }

  @override
  didChangeDependencies() {
//  _showWellcomeDialog();
    super.didChangeDependencies();
  }


}
