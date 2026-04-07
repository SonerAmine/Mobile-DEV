import 'package:flutter/material.dart';
import 'auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  final service = AuthService();

  void resetPassword() async {
    if (emailController.text.isEmpty) {
      showMsg("Insert your email");
      return;
    }

    if (!service.isValidEmail(emailController.text)) {
      showMsg("Email invalide");
      return;
    }

    try {
      await service.resetPassword(emailController.text);
      showMsg("Password reset email sent !");
      Navigator.pop(context);
    } catch (e) {
      showMsg("Error: ${e.toString()}");
    }
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: const Text("Send Reset Email"),
            ),
          ],
        ),
      ),
    );
  }
}