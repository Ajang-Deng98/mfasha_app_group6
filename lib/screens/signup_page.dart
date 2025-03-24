import 'package:flutter/material.dart';
import 'login_page.dart';
import '../widgets/text_field_widget.dart';
import '../widgets/logo_widget.dart';
import '../services/auth-services.dart';
import '../widgets/text_field_widget.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // SingleChildScrollView for scrollable page
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the top
              children: [
                LogoWidget(),
                const SizedBox(height: 20),
                TextFieldWidget(
                  label: "Full Name",
                  hint: "Enter Your Full Name",
                  controller: _fullNameController,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: "Username",
                  hint: "Enter Your Username",
                  controller: _usernameController,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: "Email",
                  hint: "Enter Your Email",
                  controller: _emailController,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: "Password",
                  hint: "Enter Your Password",
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 10),
                TextFieldWidget(
                  label: "Phone Number",
                  hint: "Enter Your Phone Number",
                  controller: _phoneNumberController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().signup(
                      fullName: _fullNameController.text.trim(),
                      username: _usernameController.text.trim(),
                      email: _emailController.text.trim(),
                      password: _passwordController.text.trim(),
                      phoneNumber: _phoneNumberController.text.trim(),
                      context: context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an Account? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Go to Login",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
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