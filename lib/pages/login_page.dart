import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/pages/register_page.dart';
import 'package:chat_app/service/auth_service.dart';
import 'package:chat_app/widgets/components.dart';
import 'package:chat_app/widgets/alerts.dart';
import 'package:chat_app/widgets/navigation.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
                  child: Form(
                    key: formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            'ChatApp',
                            style: TextStyle(
                                fontSize: 50, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10, width: double.infinity),
                          const Text(
                            'Login and start chatting!',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Image.asset("assets/login.png", height: 250),
                          const SizedBox(
                            height: 50,
                          ),
                          TextFormField(
                            onChanged: (val) => setState(() => email = val),
                            decoration: textInputDecoration.copyWith(
                              labelText: 'Email',
                              prefixIcon:
                                  const Icon(Icons.email, color: Colors.blue),
                            ),
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val!)
                                  ? null
                                  : 'Please enter a valid email';
                            },
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            obscureText: true,
                            validator: (val) {
                              return val!.length > 5
                                  ? null
                                  : 'The password must be 6+ characters';
                            },
                            onChanged: (val) => setState(() => password = val),
                            decoration: textInputDecoration.copyWith(
                              labelText: 'Password',
                              prefixIcon:
                                  const Icon(Icons.lock, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(
                            height: 28,
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                              ),
                              child: const Text('Login',
                                  style: TextStyle(fontSize: 18)),
                              onPressed: () {
                                login();
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(fontSize: 16),
                              ),
                              TextButton(
                                onPressed: () {
                                  nextScreen(context, const RegisterPage());
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text('Register',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 21.5,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ]),
                  )),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      await authService.signIn(email, password).then((res) {
        if (res == true) {
          nextScreenReplace(context, const HomePage());
        } else {
          setState(() => isLoading = false);
          showSnackBar(context, Colors.red, res.toString().split('] ')[1]);
        }
      });
    }
  }
}
