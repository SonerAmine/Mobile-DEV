import 'package:flutter/material.dart';
import 'signup_page.dart';
import 'auth_service.dart';
import 'reset_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginEmail = TextEditingController();
  final loginPwd = TextEditingController();
  final service = AuthService();

  void login() async {
    if (!service.isValidEmail(loginEmail.text)) {
      showMsg("Email invalide");
      return;
    }

    if (loginPwd.text.isEmpty) {
      showMsg("Insert Password");
      return;
    }

    try {
      await service.login(loginEmail.text, loginPwd.text);
    } catch (e) {
      String errorMsg = "An error occurred";
      if (e.toString().contains("user-not-found")) {
        errorMsg = "No account found with this email";
      } else if (e.toString().contains("wrong-password") ||
          e.toString().contains("invalid-credential")) {
        errorMsg = "Incorrect password";
      } else if (e.toString().contains("invalid-email")) {
        errorMsg = "Invalid email address";
      } else if (e.toString().contains("network-request-failed")) {
        errorMsg = "Network error, check your connection";
      } else if (e.toString().contains("too-many-requests")) {
        errorMsg = "Too many attempts. Try again later";
      }
      showMsg(errorMsg);
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: loginEmail,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: loginPwd,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
                );
              },
              child: const Text("Forgot password ?"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't you have an account ?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text("Signup"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}