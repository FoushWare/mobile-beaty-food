import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthProvider>().verifyOtp(
            widget.phone,
            _otpController.text,
          );

      if (success && mounted) {
        // Navigate to profile completion screen
        Navigator.pushReplacementNamed(
          context,
          '/complete-basic-profile',
          arguments: widget.phone,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);

    try {
      await context.read<AuthProvider>().sendOtp(widget.phone);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رمز التحقق'),
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
                Icons.verified_user,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'أدخل رمز التحقق',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'تم إرسال رمز التحقق إلى ${widget.phone}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // OTP Input
              CustomTextField(
                controller: _otpController,
                labelText: 'رمز التحقق',
                hintText: '1234',
                prefixIcon: Icons.lock_outline,
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال رمز التحقق';
                  }
                  if (value.length != 4) {
                    return 'رمز التحقق يجب أن يكون 4 أرقام';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Verify OTP Button
              CustomButton(
                onPressed: _isLoading ? null : _verifyOtp,
                text: _isLoading ? 'جاري التحقق...' : 'تحقق من الرمز',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لم تستلم الرمز؟ ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: _isResending ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('إعادة إرسال'),
                  ),
                ],
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
                      'استخدم هذا الرمز للاختبار',
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
