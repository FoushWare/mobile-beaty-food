import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CompleteBasicProfileScreen extends StatefulWidget {
  final String phone;

  const CompleteBasicProfileScreen({
    super.key,
    required this.phone,
  });

  @override
  State<CompleteBasicProfileScreen> createState() => _CompleteBasicProfileScreenState();
}

class _CompleteBasicProfileScreenState extends State<CompleteBasicProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  UserType _selectedUserType = UserType.customer;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await context.read<AuthProvider>().completeBasicProfile(
        phone: widget.phone,
        name: _nameController.text,
        email: _emailController.text,
        userType: _selectedUserType,
      );
      
      if (success && mounted) {
        // Navigate to main app or profile completion
        if (_selectedUserType == UserType.chef) {
          Navigator.pushReplacementNamed(
            context,
            '/complete-chef-verification',
            arguments: widget.phone,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/complete-profile',
            arguments: widget.phone,
          );
        }
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
        title: const Text('إكمال الملف الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'أكمل ملفك الشخصي',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'أخبرنا المزيد عنك لتحسين تجربتك',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Name Input
              CustomTextField(
                controller: _nameController,
                labelText: 'الاسم الكامل',
                hintText: 'أحمد محمد',
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  if (value.length < 3) {
                    return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Email Input
              CustomTextField(
                controller: _emailController,
                labelText: 'البريد الإلكتروني',
                hintText: 'ahmed@example.com',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // User Type Selection
              const Text(
                'نوع المستخدم',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    RadioListTile<UserType>(
                      title: const Row(
                        children: [
                          Icon(Icons.restaurant_menu, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('عميل'),
                        ],
                      ),
                      value: UserType.customer,
                      groupValue: _selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                        });
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<UserType>(
                      title: const Row(
                        children: [
                          Icon(Icons.chef_hat, color: Colors.green),
                          SizedBox(width: 12),
                          Text('شيف'),
                        ],
                      ),
                      value: UserType.chef,
                      groupValue: _selectedUserType,
                      onChanged: (value) {
                        setState(() {
                          _selectedUserType = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Complete Profile Button
              CustomButton(
                onPressed: _isLoading ? null : _completeProfile,
                text: _isLoading ? 'جاري الحفظ...' : 'إكمال الملف الشخصي',
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),

              // Info about next steps
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'الخطوات التالية',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedUserType == UserType.chef
                          ? 'ستحتاج لإكمال معلومات الشيف والتحقق من الوثائق'
                          : 'ستحتاج لإكمال العنوان والتفضيلات الغذائية',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
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


