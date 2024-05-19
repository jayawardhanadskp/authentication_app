import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

import 'home_page.dart';
import 'register_page.dart';


class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // user sign in method
  void SignInUser() async{

    if (_formKey.currentState!.validate()) {
       try {
         await FirebaseAuth.instance.signInWithEmailAndPassword(
             email: emailController.text,
             password: passwordController.text
         );
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Sign in sucessfully')),
         );

         // navigete to home page
         Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePage()));

       } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Failed to login: $e')),
         );
       }
    }
  }

  // ccheack google user signup
  Future<bool> isUserSignedUp(String? userId) async {
    try {
      if (userId != null) {
        DocumentSnapshot<Object?> userDocument =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();
        return userDocument.exists;
      }
      return false;
    } catch (e) {
      print('error cahecking user is singed up: $e');
      return false;
    }
  }

  // google user signin
  signInGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential authResult = await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;

        // check google user signed up
        bool isSigedUp = await isUserSignedUp(user?.uid);

        if (isSigedUp) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> const HomePage()));

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign up first'))
          );

          Navigator.push(context, MaterialPageRoute(builder: (context)=> const SignUpPage()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              // logo
              Lottie.network(
                  'https://lottie.host/ae7a2318-7f20-4809-bc2a-b9f1f1432aeb/oXj01sZRKe.json'),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Hello! Welcome Back',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(
                height: 20,
              ),

              // email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.green,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'E-mail'),
                  controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Email';
                    }

                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'please enter valid email';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              // password
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    prefixIcon: Icon(
                      Icons.password,
                      color: Colors.green,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                  ),
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(
                height: 30,
              ),
              // signin button
              ElevatedButton(
                  onPressed: SignInUser,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(15),
                      fixedSize: const Size(200, 60),
                      textStyle:
                      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green.shade900,
                      elevation: 5,
                      shadowColor: Colors.green.shade900),
                  child: const Text('Sign In')),
              const SizedBox(
                height: 15,
              ),

              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.9,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Or Continue With',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                      child: Divider(
                        thickness: 0.9,
                        color: Colors.white,
                      ))
                ],
              ),
              const SizedBox(height: 10,),

              // google button
              GestureDetector(
                onTap: signInGoogle,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/google-logo-for_button.jpg',
                      height: 70 ,
                    )
                ),
              ),

              // havent acount
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const SignUpPage()));
                  },
                  child: const Text(
                    'Dont\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
