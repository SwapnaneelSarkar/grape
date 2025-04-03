import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../color_constant/color_constant.dart';
import 'bloc.dart';
import 'event.dart';
import 'state.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // ✅ Form validation key

  @override
  void initState() {
    super.initState();
    // ✅ Ensure Bloc event is called after the widget tree is built
    Future.delayed(Duration.zero, () {
      context.read<LoginBloc>().add(CheckLoginStatus());
    });
  }

  void _onLoginPressed(BuildContext context) {
    if (!_formKey.currentState!.validate())
      return; // ✅ Prevent invalid submission

    FocusScope.of(context).unfocus(); // ✅ Hide keyboard before login

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Login to continue",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              BlocConsumer<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is LoginSuccess) {
                    print("✅ Login Success Listener: Navigating to Home...");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Welcome ${state.name}!')),
                    );
                    Future.microtask(() {
                      Navigator.pushReplacementNamed(context, '/home');
                    });
                  } else if (state is LoginFailure) {
                    print("❌ Login Failure: ${state.error}");
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.error)));
                  }
                },

                builder: (context, state) {
                  return Form(
                    key: _formKey, // ✅ Wrap in Form for validation
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: "Email",
                            hintText: "Enter your email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email is required";
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return "Enter a valid email";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "Enter your password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Password is required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                          onFieldSubmitted:
                              (_) => _onLoginPressed(
                                context,
                              ), // ✅ Press Enter to submit
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed:
                              state is! LoginLoading
                                  ? () => _onLoginPressed(context)
                                  : null,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: AppColors.buttonText,
                            backgroundColor: AppColors.primary,
                          ),
                          child:
                              state is LoginLoading
                                  ? const CircularProgressIndicator(
                                    color: AppColors.buttonText,
                                  )
                                  : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
