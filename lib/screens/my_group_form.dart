import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviz/functions/get_regno.dart';
import 'package:serviz/functions/getusername.dart';
import 'package:serviz/utils/colors.dart';
import 'package:serviz/widgets/appbar.dart';
import 'package:get/get.dart';
import 'package:flutter_bounce/flutter_bounce.dart';

class MyGroupForm extends StatefulWidget {
  const MyGroupForm({super.key});

  @override
  State<MyGroupForm> createState() => _MyGroupFormState();
}

class _MyGroupFormState extends State<MyGroupForm> {
  final useruid = FirebaseAuth.instance.currentUser!.uid;
  String username = '';
  String grp_num = '';
  String faculty_name = '';
  List members = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey_background,
      appBar: MyBackAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: FutureBuilder(
                    future: getMyGroupDetails(),
                    builder: (context, snapshot) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 1 / 7,
                        width: MediaQuery.of(context).size.width - 50,
                        decoration: BoxDecoration(
                            color: AppColors.black_background,
                            borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Icon(
                              Icons.groups_rounded,
                              color: AppColors.white_text,
                              size: 55,
                            ),
                            Text(grp_num,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                    color: AppColors.yellow_accent)),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: MediaQuery.of(context).size.height * 1 / 2,
                  width: MediaQuery.of(context).size.width - 50,
                  decoration: BoxDecoration(
                      color: AppColors.black_background,
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: FutureBuilder(
                      future: getMyGroupDetails(),
                      builder: (context, snapshot) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text("Faculty in Charge",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: AppColors.yellow_accent)),
                                    SizedBox(height: 10),
                                    Text(faculty_name,
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: AppColors.white_text)),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'Team Members',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: AppColors.yellow_accent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: members.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        members[index],
                                        style: GoogleFonts.poppins(
                                            color: AppColors.white_text),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Bounce(
            duration: Duration(milliseconds: 110),
            onPressed: () {
              //What to do on pressed
              exitGroup();
            },
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              height: MediaQuery.of(context).size.height * 1 / 15,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: AppColors.black_background,
                  border: Border.all(color: AppColors.red_text, width: 2)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.exit_to_app_rounded,
                    color: AppColors.red_text,
                  ),
                  Text(
                    'Exit Group',
                    style: GoogleFonts.poppins(
                        color: AppColors.red_text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  getMyGroupNum() async {
    var grp_num = await GetRegNo(documentID: useruid).getcollectiongrpno();
  }

  getMyGroupDetails() async {
    grp_num = await GetRegNo(documentID: useruid).getcollectiongrpno();
    username = await GetRegNo(documentID: useruid).getcollectionusername();

    await FirebaseFirestore.instance
        .collection('group')
        .doc(grp_num)
        .get()
        .then((data) => {
              faculty_name = data['faculty_name'],
              members = data['members'],
            });
  }

  exitGroup() async {
    try {
      //grp_num = await GetRegNo(documentID: useruid).getcollectiongrpno();

      await FirebaseFirestore.instance.collection('group').doc(grp_num).update({
        'members': FieldValue.arrayRemove([username])
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(useruid)
          .update({'grp_id': 'null'});

      Get.snackbar("Successfull", "Exited group");
      Get.offAllNamed('/createjoingroup');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
