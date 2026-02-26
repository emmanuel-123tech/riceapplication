import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final orgCtrl = TextEditingController();
  String role = 'Farmer';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name / Username*')),
            DropdownButtonFormField<String>(
              value: role,
              items: const ['Farmer', 'Trader', 'Miller', 'Other']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => role = v ?? 'Farmer'),
              decoration: const InputDecoration(labelText: 'Role'),
            ),
            TextField(controller: orgCtrl, decoration: const InputDecoration(labelText: 'Organisation (optional)')),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name is required')));
                  return;
                }
                await context.read<AppController>().saveUserProfile(nameCtrl.text.trim(), role, orgCtrl.text.trim());
                if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text('Continue'),
            )
          ],
        ),
      ),
    );
  }
}
