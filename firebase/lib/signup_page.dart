import 'package:flutter/material.dart';
import 'auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final service = AuthService();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final confirmEmail = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  DateTime? dob;

  void signup() async {
    if (firstName.text.isEmpty || lastName.text.isEmpty || email.text.isEmpty) {
      showMsg("Insert all fields");
      return;
    }

    if (password.text.length < 6) {
      showMsg("Weak Password, use at least 6 characters");
      return;
    }

    if (dob == null) {
      showMsg("Select date of birth");
      return;
    }

    if (!service.isAtLeast13(dob!)) {
      showMsg("Must be 13+");
      return;
    }

    if (email.text != confirmEmail.text) {
      showMsg("Emails do not match");
      return;
    }

    if (password.text != confirmPassword.text) {
      showMsg("Passwords do not match");
      return;
    }

    try {
      await service.signup(
        firstName: firstName.text,
        lastName: lastName.text,
        dob: dob!,
        email: email.text,
        password: password.text,
      );
      Navigator.pop(context);
    } catch (e) {
      String errorMsg = "An error occurred";
      if (e.toString().contains("email-already-in-use")) {
        errorMsg = "This email is already used by another account";
      } else if (e.toString().contains("weak-password")) {
        errorMsg = "Password is too weak";
      } else if (e.toString().contains("invalid-email")) {
        errorMsg = "Invalid email address";
      } else if (e.toString().contains("network-request-failed")) {
        errorMsg = "Network error, check your connection";
      } else if (e.toString().contains("PERMISSION_DENIED")) {
        errorMsg = "Firestore not enabled. Please activate it in Firebase Console";
      }
      showMsg(errorMsg);
    }
  }

  void pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2000),
    );
    if (picked != null) setState(() => dob = picked);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: firstName,
              decoration: const InputDecoration(labelText: "First name"),
            ),
            TextField(
              controller: lastName,
              decoration: const InputDecoration(labelText: "Last name"),
            ),
            ListTile(
              title: Text(
                dob == null ? "Date of birth" : dob.toString().split(" ")[0],
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickDate,
            ),
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: confirmEmail,
              decoration: const InputDecoration(labelText: "Confirm Email"),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            TextField(
              controller: confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signup,
              child: const Text("Create Account"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account ?"),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}