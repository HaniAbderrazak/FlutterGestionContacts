import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'SignUp.dart';
import 'main.dart'; // Import the NavigationPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

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

      return await _auth.signInWithCredential(credential);
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
    }
  }

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if the user exists in Firebase
      User? user = _auth.currentUser;
      if (user != null) {
        // Navigate to the NavigationPage after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigationPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      // Handle login error
    } catch (e) {
      print('Error: $e');
      // Handle other errors
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
                      'assets/login.jpg',
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
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(150, 50),
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                              elevation: 5,
                            ),
                            child: Text('Login'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUpPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size(150, 50),
                              primary: Colors.indigo,
                              onPrimary: Colors.white,
                              elevation: 5,
                            ),
                            child: Text('Sign Up'),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          UserCredential? userCredential = await _handleGoogleSignIn();
                          if (userCredential != null) {
                            // Check if the user exists in Firebase
                            User? user = _auth.currentUser;
                            if (user != null) {
                              // Navigate to the NavigationPage after successful Google sign-in
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => NavigationPage()),
                              );
                              print("Google Sign-In Successful!");
                            }
                          } else {
                            // Handle sign-in error
                            print("Google Sign-In Failed!");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          primary: Colors.indigo,
                          onPrimary: Colors.white,
                          elevation: 5,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/google_icon.png', // Replace with your Google icon asset
                              height: 60,
                              width: 24,
                            ),
                            SizedBox(width: 60),
                            Text('Sign in with Google'),
                          ],
                        ),
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
