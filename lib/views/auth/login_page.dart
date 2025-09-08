import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // Navigation handled by main.dart with StreamBuilder on auth state
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text("Fabrication Tracking",
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 24),
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
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Login"),
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
