import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:baty_bites/core/router/app_router.dart';
import 'package:baty_bites/core/constants/app_constants.dart';
import 'package:baty_bites/providers/auth_provider.dart';
import 'package:baty_bites/widgets/common/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppRouter.pop(),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: Text('لا توجد بيانات المستخدم'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.largeSpacing),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          backgroundImage: user.profileImage.isNotEmpty 
                              ? NetworkImage(user.profileImage) 
                              : null,
                          child: user.profileImage.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: colorScheme.onPrimaryContainer,
                                )
                              : null,
                        ),
                        const SizedBox(height: AppConstants.defaultSpacing),
                        Text(
                          user.fullName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallSpacing),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.userType.name == 'customer' ? 'عميل' : 'طاهي',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.largeSpacing),
                
                // Profile Actions
                _buildProfileSection(
                  context,
                  'الإعدادات العامة',
                  [
                    _buildProfileTile(
                      context,
                      Icons.edit,
                      'تعديل الملف الشخصي',
                      () => _showComingSoon(context),
                    ),
                    _buildProfileTile(
                      context,
                      Icons.location_on,
                      'إدارة العناوين',
                      () => _showComingSoon(context),
                    ),
                    _buildProfileTile(
                      context,
                      Icons.notifications,
                      'الإشعارات',
                      () => _showComingSoon(context),
                    ),
                    _buildProfileTile(
                      context,
                      Icons.language,
                      'اللغة',
                      () => _showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                _buildProfileSection(
                  context,
                  'المساعدة والدعم',
                  [
                    _buildProfileTile(
                      context,
                      Icons.help,
                      'مركز المساعدة',
                      () => _showComingSoon(context),
                    ),
                    _buildProfileTile(
                      context,
                      Icons.contact_support,
                      'تواصل معنا',
                      () => _showComingSoon(context),
                    ),
                    _buildProfileTile(
                      context,
                      Icons.privacy_tip,
                      'سياسة الخصوصية',
                      () => _showComingSoon(context),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.largeSpacing),
                
                // Logout Button
                AppButton.outlined(
                  text: 'تسجيل الخروج',
                  onPressed: () => _logout(context, authProvider),
                  isExpanded: true,
                  icon: const Icon(Icons.logout),
                ),
                
                const SizedBox(height: AppConstants.defaultSpacing),
                
                // App Info
                Text(
                  'إصدار التطبيق 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileSection(
    BuildContext context, 
    String title, 
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: AppConstants.smallSpacing),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium,
        textDirection: TextDirection.rtl,
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة قيد التطوير وستكون متاحة قريباً'),
      ),
    );
  }

  void _logout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تسجيل الخروج',
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.logout();
              AppRouter.go(AppRouter.welcome);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}