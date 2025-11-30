import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/landing/views/landing_ui.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import 'package:locket_beta/model/login_model.dart';
import 'package:locket_beta/home/view/home.dart';
import "package:locket_beta/landing/views/landing_ui.dart";

class LoginUI extends StatefulWidget {
  const LoginUI({super.key});

  @override
  State<LoginUI> createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late LoginModel _loginModel;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateTextControllers(LoginModel form) {
    if (_emailController.text != form.email) {
      _emailController.text = form.email;
      _emailController.selection = TextSelection.fromPosition(
        TextPosition(offset: form.email.length),
      );
    }

    if (_passwordController.text != form.password) {
      _passwordController.text = form.password;
      _passwordController.selection = TextSelection.fromPosition(
        TextPosition(offset: form.password.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loginModel = LoginModel(
      email: '',
      password: '',
      showPassword: false,
      userId: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              } else if (state is LoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              }
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LandingUI())),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "What's your Email?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInputField(
                    controller: _emailController,
                    hintText: 'Email Address',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your Password?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildInputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: 'By tapping Continue, you agree to our ',
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' and ',
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 270,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is LoginLoading
                            ? null
                            : () {
                                final email = _emailController.text.trim();
                                final password =
                                    _passwordController.text.trim();
                                context
                                    .read<LoginCubit>()
                                    .login(email, password);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: state is LoginLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_loginModel.showPassword,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _loginModel.showPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _loginModel = LoginModel(
                      email: _emailController.text,
                      password: _passwordController.text,
                      showPassword: !_loginModel.showPassword,
                      userId: null,
                    );
                  });
                },
              )
            : null,
      ),
    );
  }
}
