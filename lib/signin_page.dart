import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:test_camera_detection/home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  List<String> _validate(String email, String password) {
    final errors = <String>[];
    final emailRegex = RegExp(r"^[\w\.\-]+@[\w\-]+(\.[\w\-]+)+$");
    if (!emailRegex.hasMatch(email)) {
      errors.add("user name email only ");
    }
    if (password.length < 8) {
      errors.add("password must be length more than 8");
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      errors.add("password must have 1 number");
    }
    if (!RegExp(r'[!@#\$%\^&*(),.?":{}|<>]').hasMatch(password)) {
      errors.add("password must have 1 special characterว");
    }
    return errors;
  }

  Future<Map<String, String>> _encryptCredentials(
    String email,
    String password,
  ) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = await algorithm.newSecretKey();
    final nonce = algorithm.newNonce();
    final plain = utf8.encode(
      jsonEncode({'username': email, 'password': password}),
    );
    final secretBox = await algorithm.encrypt(
      plain,
      secretKey: secretKey,
      nonce: nonce,
    );

    final keyBytes = await secretKey.extractBytes();

    return {
      'cipherText': base64.encode(secretBox.cipherText),
      'nonce': base64.encode(secretBox.nonce),
      'mac': base64.encode(secretBox.mac.bytes),
      'key': base64.encode(keyBytes),
    };
  }

  void _handleSignIn() async {
    final nav = Navigator.of(context);
    final email = _emailController.text.trim();
    final password = _passController.text;

    final errors = _validate(email, password);
    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (c) => AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "Please Check Format Username or Password",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children:
                    errors
                        .map(
                          (e) => Text(
                            "• $e",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        )
                        .toList(),
              ),
              actions: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(c);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      );
      return;
    }

    final encrypted = await _encryptCredentials(email, password).then((_) {
      nav.push(MaterialPageRoute(builder: (context) => HomePage()));
    });
    debugPrint("Encrypted data: $encrypted");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Sign In",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.network(
                  'https://assets.brandinside.asia/uploads/2021/05/1620365513924..jpg',
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 2,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 2,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    _handleSignIn();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
