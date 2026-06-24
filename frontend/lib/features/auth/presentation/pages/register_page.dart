import 'package:chat_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:chat_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:chat_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:chat_app/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _phone_number_Controller = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  

  void dispose() {
    _phone_number_Controller.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    super.dispose();
  }

  void _onRegister() {
    BlocProvider.of<AuthBloc>(context).add(
      RegisterEvent(
        username: "@${_firstNameController.text.toLowerCase().substring(0, 4)}${_secondNameController.text.toLowerCase().substring(0, 4)}",
        phone_number: _phone_number_Controller.text,
        password: _passwordController.text,
        first_name: _firstNameController.text,
        second_name: _secondNameController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthInputField(
                hint: 'First Name',
                icon: Icons.person,
                controller: _firstNameController,
              ),
              SizedBox(
                height: 20,
              ),
              AuthInputField(
                hint: 'Second Name',
                icon: Icons.person,
                controller: _secondNameController,
              ),
              SizedBox(
                height: 20,
              ),
              AuthInputField(
                hint: 'Phone number',
                icon: Icons.phone,
                controller: _phone_number_Controller,
              ),
              SizedBox(
                height: 20,
              ),
              AuthInputField(
                hint: 'Password',
                icon: Icons.lock,
                controller: _passwordController,
                isPassword: true,
              ),
              SizedBox(
                height: 20,
              ),
              BlocConsumer<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return AuthButton(
                    text: 'Register',
                    onPressed: _onRegister,
                  );
                },
                listener: (context, state) {
                  if (state is AuthSuccess) {
                    Navigator.pushNamed(context, '/login');
                  } else if (state is AuthFailure) {           
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.error),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: 20,
              ),
              LoginPrompt(
                title: 'Already have an account? ',
                subtitle: 'Click here to login',
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
