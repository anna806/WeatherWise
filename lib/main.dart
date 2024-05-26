import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_wise/history_state.dart';
import 'package:weather_wise/login_state.dart';
import 'package:weather_wise/map_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'map_state.dart';
import 'user.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WeatherWiseApp());
}

class WeatherWiseApp extends StatelessWidget {
  const WeatherWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
          value: LoginState(),
        ),
          ChangeNotifierProvider.value(value: MapState()),
          ChangeNotifierProvider.value(value: HistoryState())
        ],
        child:
          MaterialApp(
            title: 'Weather Wise',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8cc7ff)),
              useMaterial3: true,
            ),
            home: LoginPage(),
            navigatorKey: navigatorKey,
        )
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({super.key});
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  _LoginPageState createState() =>
      _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  Future<void> login(BuildContext context, String email, String password, FirebaseAuth _auth) async {

    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      var db = FirebaseFirestore.instance;
      var user = MyUser(uid: "", email: "", role: "");
      await db.collection('Users').where("uid", isEqualTo: userCredential.user?.uid).limit(1).get().then(
            (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            user = MyUser(
                uid: docSnapshot['uid'] as String? ?? '',
                email: docSnapshot['email'] as String? ?? '',
                role: docSnapshot['role'] as String? ?? ''
            );
          }
        },
        onError: (e) => log("Error completing: $e"),
      );
      Provider.of<LoginState>(context, listen: false).setIsLoading(false);
      // Navigate to the next screen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(userRole: user.role as String? ?? 'normal'),
        ),
      );
    } catch (e) {
      Provider.of<LoginState>(context, listen: false).setIsLoading(false);
      log(e.toString());
      // Handle errors
      handleError(email, e.toString(), context, password, _auth);
    }
  }

  Future<void> handleError(String email, String errorMessage, BuildContext context, String password, FirebaseAuth _auth) async {
    var db = FirebaseFirestore.instance;
    var user = MyUser(uid: "", email: "", role: "");
    await db.collection('Users').where("email", isEqualTo: email).limit(1).get().then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          user = MyUser(
              uid: docSnapshot['uid'] as String? ?? '',
              email: docSnapshot['email'] as String? ?? '',
              role: docSnapshot['role'] as String? ?? ''
          );
        }
      },
      onError: (e) => log("Error completing: $e"),
    );
    if (user.uid == "") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("No user found"),
            content: const Text("User not found in the database. Would you like to register?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  handleRegister(context, email, password, _auth);
                },
                child: const Text("Yes"),
              ),
            ],
          );
        },
      );
    }
    else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Login Error"),
            content: Text(errorMessage),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> handleRegister(BuildContext context, String email, String password, FirebaseAuth _auth) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      var db = FirebaseFirestore.instance;
      await db.collection('Users').add({
        'uid': userCredential.user?.uid,
        'email': email,
        'role': 'normal'
      });
      navigatorKey.currentState!.pushReplacement(MaterialPageRoute(
        builder: (context) => MapPage(userRole: 'normal'),
      ));
    } catch (e) {
      log(e.toString());
      showDialog(
        context: navigatorKey.currentContext!,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Register error"),
            content: Text(e.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = Provider.of<LoginState>(context).isLoading;
    return PopScope (
        canPop: false,
        onPopInvoked: (_) async {
          var result = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Are you sure?"),
                content: const Text("Do you really want to quit?"),
                actions: [
                  TextButton(
                    child: const Text("No"),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  TextButton(
                    child: const Text("Yes"),
                    onPressed: () => SystemNavigator.pop(),
                  ),
                ],
              );
            },
          );
          return result ?? false;
        },
        child:
        Scaffold(
            body: SafeArea(
                child: SingleChildScrollView(
                    child:
                    Center(
                      child: Column(
                        children: [
                          Container(
                              height: MediaQuery.of(context).size.height * 0.45,
                              width: MediaQuery.of(context).size.width,
                              decoration: const BoxDecoration(
                                color: Color(0xFF8cc7ff),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(25.0),
                                ),
                              ),
                              child: Center(
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        Image.asset('assets/images/weather_logo.png', height: 246, width: 246),
                                        const SizedBox(height: 10),
                                        Text("Log In", style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                                fontSize: 35,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                            ))
                                        )
                                      ]
                                  )
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.all(30),
                            child:
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Username", style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black
                                      ))
                                  ),
                                  TextField(
                                    controller: widget._emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        hintText: 'Enter username',
                                        hintStyle: GoogleFonts.lato(
                                            textStyle: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey
                                            ))
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text("Password", style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black
                                      ))
                                  ),
                                  TextField(
                                    controller: widget._passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        hintText: 'Enter password',
                                        hintStyle: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey
                                        )
                                    ),
                                  ),
                                  const SizedBox(height: 60),
                                  Center(
                                    child: isLoading
                                        ? const CircularProgressIndicator()
                                        : TextButton(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: const Color(0xFF8cc7ff),
                                        minimumSize: const Size(double.infinity, 57),
                                      ),
                                      onPressed: () {
                                        if(widget._emailController.text.isNotEmpty && widget._passwordController.text.isNotEmpty) {
                                          Provider.of<LoginState>(context, listen: false).setIsLoading(true);
                                          login(context, widget._emailController.text.trim(), widget._passwordController.text.trim(), FirebaseAuth.instance);
                                        }
                                        else {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Empty fields"),
                                                content: const Text("Please enter both username and password."),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                          child: Text('Log In', style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white
                                              )
                                          )),
                                    ),
                                  ),
                                ]
                            ),
                          ),

                        ],
                      ),
                    )
                )
            )
        )
    );
  }
}