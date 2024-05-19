import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  User? user;
  Map<String, dynamic>? userData;

  // fetch user data from firestore
  Future<void> fetchUserData() async {
    user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        setState(() {
          userData = snapshot.data();
        });
      }
    } catch (er) {
      print('Error fetching data: $er');
    }
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: userData == null
      ? const Center(child: CircularProgressIndicator(),)
      :
      Center(
        child: Column(

          children: [
            Lottie.network(
                'https://lottie.host/ae7a2318-7f20-4809-bc2a-b9f1f1432aeb/oXj01sZRKe.json'),
            const SizedBox(
              height: 20,
            ),

            // photo
            if (userData!['profilePicture'] != null && userData!['profilePicture'].isNotEmpty)
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(userData!['profilePicture']),
            )
            else
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
            const SizedBox(height: 20,),

            // name
            Text(
              userData!['username'] ?? '',
              style: const TextStyle(fontSize: 20, ),
            ),
            const SizedBox(height: 10,),

            //email
            Text(
             userData!['email'] ?? '',
             style: const TextStyle(fontSize: 18),
            )

          ],
        ),
      )

    );
  }
}
