import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.registerUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        displayName: _nameController.text.trim(),
      );
      // User created → needs admin to activate & assign role
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful. Wait for admin approval."),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Text(_error!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 14)),
                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Register"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
