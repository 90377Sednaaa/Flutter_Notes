import 'package:flutter/material.dart';
import 'package:notes/auth_service.dart';
import 'package:notes/home_page.dart';
import 'package:notes/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService auth = AuthService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Email login ---
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ), // InputDecoration
              ), // TextField
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text("Forgot Password?"),
                  onPressed: () async {
                    if (emailCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Please enter your email first"),
                        ),
                      );
                      return;
                    }
                    final success = await auth.sendPasswordResetEmail(
                      emailCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? "Password reset email sent! Check your inbox."
                              : "Failed to send reset email. Verify your email.",
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                child: loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Login with Email"),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithEmail(
                    emailCtrl.text,
                    passwordCtrl.text,
                  );
                  if (!mounted) return;
                  setState(() => loading = false);

                  if (user != null) {
                    if (!user.emailVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Please verify your email before logging in.",
                          ),
                        ), // SnackBar
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Invalid email or password")),
                    );
                  }
                },
              ), // ElevatedButton
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("OR"),
                  ), // Padding
                  Expanded(child: Divider()),
                ],
              ), // Row
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text("Sign in with Google"),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithGoogle();
                  if (!mounted) return;
                  setState(() => loading = false);
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  }
                },
              ), // ElevatedButton.icon
              SizedBox(height: 12),
              TextButton(
                child: Text("Don't have an account? Register"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterPage()),
                  );
                },
              ), // TextButton
            ],
          ), // Column
        ), // SingleChildScrollView
      ), // Center
    ); // Scaffold
  }
}
