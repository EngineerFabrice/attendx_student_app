import 'package:flutter/material.dart';
import '../data/auth_api.dart';
import '../../../shared/widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _api = AuthApi();

  // Step 1: enter email → receive reset code
  // Step 2: enter code + new password
  int _step = 1;

  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _showPass   = false;
  String? _devToken;

  Future<void> _requestReset() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      final res = await _api.forgotPassword(_emailCtrl.text.trim());
      final data = res.data['data'] as Map<String, dynamic>;
      _devToken = data['resetToken'] as String?;
      if (mounted) {
        setState(() {
          _step = 2;
          _loading = false;
        });
        if (_devToken != null) _tokenCtrl.text = _devToken!;
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) return;
    if (_passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.resetPassword(_tokenCtrl.text.trim(), _passCtrl.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid or expired token.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_step == 1) ...[
              const Text(
                'Enter your email address and we\'ll send you a reset code.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      onPressed: _requestReset,
                      text: 'Send Reset Code',
                      width: double.infinity,
                    ),
            ] else ...[
              const Text(
                'Enter the reset code and your new password.',
                style: TextStyle(color: Colors.grey),
              ),
              if (_devToken != null)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text(
                    'Dev mode — token pre-filled: $_devToken',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              const SizedBox(height: 24),
              TextField(
                controller: _tokenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reset code',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: !_showPass,
                decoration: InputDecoration(
                  labelText: 'New password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showPass
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPass = !_showPass),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      onPressed: _resetPassword,
                      text: 'Update Password',
                      width: double.infinity,
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Back — resend code'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }
}
