import 'dart:typed_data';
import 'package:authentication_app/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // image picker
  Uint8List? _image;
  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  // signup user
  Future<void> signUpUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text
        );

        // upload image to storage
        String imageUrl = '';
        if (_image != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('profilePictures')
              .child('${userCredential.user!.uid}.jpg');

          UploadTask uploadTask = ref.putData(_image!);
          TaskSnapshot snap = await uploadTask;
          imageUrl = await snap.ref.getDownloadURL();
        }

        // save data on forestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': usernameController.text,
          'email': emailController.text,
          'profilePicture': imageUrl
        });

        // navigate to login page
        Navigator.push(context, MaterialPageRoute(builder: (context)=> const LogInPage()));

      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'))
        );
      }
    }
  }

  // save google user in firestore
  void saveGoogleUserToFirestore(User? user) async {
    if (user != null) {
      String uid = user.uid;
      String username = user.displayName ?? '';
      String email = user.email ?? '';
      String imageUrl = user.photoURL ?? '';

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'username': username,
        'email': email,
        'profilePicture': imageUrl
      });
    }
  }

  // google signup
  signInGoogle() async {
    final GoogleSignIn _googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = authResult.user;

        saveGoogleUserToFirestore(user);

        Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error google signin: $e'))
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
          
                Lottie.network(
                    'https://lottie.host/ae7a2318-7f20-4809-bc2a-b9f1f1432aeb/oXj01sZRKe.json',
                    height: 250
                ),
                // add photo
                Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green[200],
                    borderRadius: BorderRadius.circular(70),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff7DDCFB),
                        Color(0xffBC67F2),
                        Color(0xffACF6AF),
                        Color(0xffF95549),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      _image != null ? CircleAvatar(
                        radius: 60,
                        backgroundImage: MemoryImage(_image!),
                      ) : const CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage('assets/personn.png'),
                      ),
          
                      Positioned(
                        bottom: -10,
                        left: 65,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
          
                // username
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide (color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
                      prefixIcon: Icon(
                        Icons.person,
                        color: Colors.green,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'User name',
                    ),
                    controller: usernameController,
                    obscureText: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                ),
          
                const SizedBox(height: 15,),
          
                // email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.green,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'E-mail'
                    ),
          
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
                const SizedBox(height: 15,),
          
                // password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide (color: Colors.white)
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)
                      ),
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
                      if (value ==null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30,),
          
                // sigup buttom
                ElevatedButton(
                    onPressed: signUpUser,
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        ),
                        padding: const EdgeInsets.all(15),
                        fixedSize: const Size(200, 60),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, ),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green.shade900,
                        elevation: 5,
                        shadowColor: Colors.green.shade900
                    ),
                    child: const Text('Sing Up')
                ),
          
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
                          MaterialPageRoute(builder: (context) => const LogInPage()));
                    },
                    child: const Text(
                      'Have an account? Sign In',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ))
          
              ],
            ),
          ),
        )


    );
  }
}

//image picker
pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  print('${_file?.path}');
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Image Selected');
}