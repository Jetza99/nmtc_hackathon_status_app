import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nmtc_hackathon_status/UserManager.dart';
import 'package:nmtc_hackathon_status/status_screen.dart';
import 'firebase_options.dart';
import 'package:page_transition/page_transition.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NMTC Hackathon Status',
      home: const MyHomePage(title: 'NMTC Hackathon Status'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  bool isSigningIn = false;

  final emailController = TextEditingController();
  final pwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6E0DAD), Color(0xFF0062A3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'NMTC V4.0',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 30.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  'NMTC Hackathon Status',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30.0),
                buildTextField(emailController, 'Email', Icons.email),
                SizedBox(height: 20.0),
                buildTextField(pwdController, 'Password', Icons.lock, obscureText: true),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: () {
                    signIn();
                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                      Size(150, 50) // Set the height as needed
                    ),
                  ),
                  child: isSigningIn
                      ? CircularProgressIndicator() // Show CircularProgressIndicator while signing in
                      : Text(
                      'Sign In',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return Container(
      width: 300.0,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          prefixIcon: Icon(icon, color: Colors.white),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    String email = emailController.text;
    String pwd = pwdController.text;

    UserManager userManager = UserManager();

    try {
      setState(() {
        isSigningIn = true; // Set the flag to true when signing in starts
      });

      User? user = await userManager.signInWithEmailAndPassword(email, pwd);

      if(user != null){
        Navigator.push(context, PageTransition(child: StatusScreen(), type: PageTransitionType.leftToRight));

      }else{
        print('user do not exist');
      }

    } catch (error) {
      print(error);

    } finally {
      setState(() {
        isSigningIn = false; // Set the flag back to false when signing in is complete
      });
    }





  }
}
