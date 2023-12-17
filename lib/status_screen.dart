import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';


class StatusScreen extends StatefulWidget {
  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  late String selectedStatus = '';
  late String? userEmail;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        print('User is currently signed out!');
        if (userEmail != null) {
          await updateStatus('Offline', userEmail!);
        }
      } else {
        print('User is signed in!');
        userEmail = FirebaseAuth.instance.currentUser?.email;
        if (userEmail != null) {
          await updateStatus('Free', userEmail!);
          selectedStatus = 'Free';
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6E0DAD), Color(0xFF0062A3)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No users available.');
                  }

                  var users = snapshot.data!.docs;
                  var userDataList = users
                      .map((user) => user.data() as Map<String, dynamic>)
                      .toList();

                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'NMTC V4.0',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'NMTC Hackathon Status',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 16.0,
                          color: Colors.white,
                        ),
                      ),


                      SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Organizer',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 23),
                              ),
                              Spacer(),
                              Text(
                                'Status',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 23),
                              ),
                              Spacer(),
                              Text(
                                'Phone',
                                style:
                                    TextStyle(color: Colors.white, fontSize: 23),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: 30,
                          ),
                          for (var userData in userDataList)
                            Column(
                              children: [
                                Organizer(
                                  name: userData['name'] ?? 'N/A',
                                  status: userData['status'] ?? 'N/A',
                                  number: userData['number'] ?? 'N/A',
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          buildStatusButton('Free'),
                          buildStatusButton('Busy'),
                          buildStatusButton('On Duty'),
                          buildStatusButton('On Break'),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0.0),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          String? userEmail =
                              FirebaseAuth.instance.currentUser?.email;

                          final users =
                              FirebaseFirestore.instance.collection('users');

                          // Query documents where 'id' field is equal to the user's email
                          var querySnapshot = await users
                              .where("id", isEqualTo: userEmail)
                              .get();
                          // Check if there's at least one matching document
                          if (querySnapshot.docs.isNotEmpty) {
                            var userDoc = querySnapshot.docs[0];

                            // Update the 'status' field in Firestore
                            await userDoc.reference
                                .update({'status': 'Offline'});
                          }
                          FirebaseAuth.instance.signOut();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildStatusButton(String status) {

    return ElevatedButton(
      onPressed: status != selectedStatus
          ? () {
              setState(() {
                userEmail = FirebaseAuth.instance.currentUser?.email;
                updateStatus(status, userEmail!);
              });
            }
          : null,
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            return status == selectedStatus ? Colors.green : null;
          }),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0)))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(getIconForStatus(status)),
          SizedBox(width: 8), // Adjust spacing between icon and text
          Text(status),
        ],
      ),
    );
  }

  Future<void> updateStatus(String status, String userId) async {
    selectedStatus = status;
    final users = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await users.where("id", isEqualTo: userId).get();

    if (querySnapshot.docs.isNotEmpty) {
      var userDoc = querySnapshot.docs[0];

      await userDoc.reference.update({'status': status});
    }
  }

  IconData getIconForStatus(String status) {
    switch (status) {
      case 'Free':
        return Icons.free_breakfast;
      case 'Busy':
        return Icons.access_alarm;
      case 'On Duty':
        return Icons.check;
      case 'On Break':
        return Icons.coffee;
      default:
        return Icons.help; // Default icon if the status is not recognized
    }
  }
}

class Organizer extends StatelessWidget {
  final String name;
  final String status;
  final String number;

  const Organizer({
    super.key,
    required this.name,
    required this.status,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: TextStyle(color: Colors.white, fontSize: 20),
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                status,
                style: TextStyle(
                    color: status == "Free" ? Colors.green:
                    status == "Busy" ? Colors.red:
                    status == "On Duty" ? Colors.yellow:
                    status == "On Break" ? Colors.blueGrey: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              var url = 'tel:${number}';
              launchUrl(Uri(scheme: 'tel', path: number));
            },
            child: Icon(
              Icons.phone,
              color: Colors.white,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
