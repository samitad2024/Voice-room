import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'phone_verification_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _selectedCountryCode = '+1';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSendCode() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _selectedCountryCode + _phoneController.text.trim();
      context.read<AuthBloc>().add(LoginWithPhoneRequested(phoneNumber));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthPhoneCodeSent) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PhoneVerificationPage(
                verificationId: state.verificationId,
                phoneNumber:
                    _selectedCountryCode + _phoneController.text.trim(),
              ),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Phone Sign In'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // Icon
                  Icon(
                    Icons.phone_android,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Enter Your Phone Number',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll send you a verification code',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Country Code & Phone Number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country Code Dropdown
                      Container(
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            borderRadius: BorderRadius.circular(12),
                            items: const [
                              DropdownMenuItem(
                                  value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(
                                  value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(
                                  value: '+91', child: Text('🇮🇳 +91')),
                              DropdownMenuItem(
                                  value: '+234', child: Text('🇳🇬 +234')),
                              DropdownMenuItem(
                                  value: '+254', child: Text('🇰🇪 +254')),
                              DropdownMenuItem(
                                  value: '+20', child: Text('🇪🇬 +20')),
                              DropdownMenuItem(
                                  value: '+966', child: Text('🇸🇦 +966')),
                              DropdownMenuItem(
                                  value: '+971', child: Text('🇦🇪 +971')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCountryCode = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Phone Number Field
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: '1234567890',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 6) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Send Code Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send Code'),
                  ),
                  const SizedBox(height: 24),

                  // Privacy Notice
                  Text(
                    'By continuing, you agree to receive an SMS verification code. Message and data rates may apply.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
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
