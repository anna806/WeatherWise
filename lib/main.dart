import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_wise/map_page.dart';

void main() {
  runApp(const WeatherWiseApp());
}

class WeatherWiseApp extends StatelessWidget {
  const WeatherWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8cc7ff)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                const Image(image: AssetImage('assets/images/weather_logo.png'), height: 246, width: 246),
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
                            controller: _emailController,
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
                            controller: _passwordController,
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
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: const Color(0xFF8cc7ff),
                              minimumSize: const Size(double.infinity, 57),
                            ),
                            onPressed: () {
                              print('Email: ${_emailController.text}');
                              print('Password: ${_passwordController.text}');
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const MapPage()));
                            },
                            child: Text('Log In', style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                )
                            )),
                          ),
                        ]
                    ),
                  ),

                ],
              ),
            )
        )
      )
    );
  }
}
