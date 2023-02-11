import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup_validation_firebase/signup.dart';

import 'home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              validator: validateEmail,
              onChanged: (value) {
                _email = value;
              },
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextFormField(
              validator: validatePassword,
              onChanged: (value) {
                _password = value;
              },
              decoration: InputDecoration(
                suffixIcon: GestureDetector(
                  onTap: _toggleObscure,
                  child: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off),
                ),
                hintText: 'Password',
              ),
              obscureText: _isObscured,
              // obscureText: true,
            ),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      loading = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: _email, password: _password);

                      if (user != null) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            )).then((value) {
                          setState(() {
                            loading = false;
                          });
                        }).onError((error, stackTrace) {
                          setState(() {
                            loading = false;
                          });
                        });
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'user-not-found') {
                        setState(() {
                          loading = false;
                        });
                        print("No User Found for that Email");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              "No User Found for that Email",
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                        );
                      } else if (e.code == 'wrong-password') {
                        setState(() {
                          loading = false;
                        });
                        print("Wrong Password Provided by User");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              "Wrong Password Provided by User",
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                        );
                      }
                    }
                  }
                },
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Login')),
            SizedBox(
              height: 20.0,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignUpPage(),
                    ));
              },
              child: Text('sign up'),
            ),
          ],
        ),
      ),
    );
  }
}

String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'E-mail address is required.';

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) return 'Invalid E-mail Address format.';

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Password is required.';

  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword))
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';

  return null;
}
