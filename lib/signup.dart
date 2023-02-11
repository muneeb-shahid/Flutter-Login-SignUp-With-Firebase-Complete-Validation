import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_signup_validation_firebase/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  late String _email, _password;
  bool _isObscured = true;

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        // final User? user = (await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _email, password: _password) )
        final User? user = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _email, password: _password)) as User?;
        print(user);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Registered Successfully. Please Login..",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        user;
        user!.sendEmailVerification();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
            (route) => false);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print("Account Already exists");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0, color: Colors.black),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: validateEmail,
                onSaved: (input) => _email = input!,
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: GestureDetector(
                    onTap: _toggleObscure,
                    child: Icon(
                        _isObscured ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                obscureText: _isObscured,
                validator: validatePassword,
                onSaved: (input) => _password = input!,
              ),
              SizedBox(
                height: 16.0,
              ),
              ElevatedButton(
                onPressed: _register,
                child: Text('Sign Up'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ));
                },
                child: Text('go to login page'),
              ),
            ],
          ),
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
