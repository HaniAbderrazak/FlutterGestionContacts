import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // You can also update the user's display name if needed
      await userCredential.user?.updateDisplayName(_nameController.text);

      // Navigate back to the login page on successful signup
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } else {
        print('Error: ${e.message}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<UserCredential?> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount == null) return null;

      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if the user is signing up for the first time
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // User is signing up for the first time, you can add additional data or perform actions here
        print("New Google User Signed Up!");
      }

      // Navigate back to the login page on successful signup/signin
      Navigator.pop(context);

      return userCredential;
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 550,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    child: Image.asset(
                      'assets/login.jpg', // Change to your sign-up image asset
                      width: double.infinity,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 150, 10, 20),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.mail, color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, color: Colors.grey),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(150, 50),
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                              elevation: 5,
                            ),
                            child: Text('Sign Up'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              UserCredential? userCredential = await _handleGoogleSignIn();
                              if (userCredential != null) {
                                // Handle the signed-in user
                                print("Google Sign-Up Successful!");
                              } else {
                                // Handle sign-in error
                                print("Google Sign-Up Failed!");
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(150, 50),
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                              elevation: 5,
                            ),
                            child: Text('Google Sign-Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
