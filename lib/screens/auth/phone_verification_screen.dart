import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthProvider>().sendOtp(_phoneController.text);
      
      if (success && mounted) {
        // Navigate to OTP verification screen
        Navigator.pushNamed(
          context,
          '/otp-verification',
          arguments: _phoneController.text,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد رقم الهاتف'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(
                Icons.phone_android,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'أدخل رقم هاتفك',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'سنرسل لك رمز التحقق عبر الرسائل النصية',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Phone Input
              CustomTextField(
                controller: _phoneController,
                labelText: 'رقم الهاتف',
                hintText: '+201234567890',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رقم الهاتف';
                  }
                  if (value.length < 10) {
                    return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Send OTP Button
              CustomButton(
                onPressed: _isLoading ? null : _sendOtp,
                text: _isLoading ? 'جاري الإرسال...' : 'إرسال رمز التحقق',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Development Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'معلومات التطوير',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'رمز التحقق الثابت: ${context.read<AuthProvider>().fixedOtp}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'في الإنتاج، سيتم إرسال الرمز عبر الرسائل النصية',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


