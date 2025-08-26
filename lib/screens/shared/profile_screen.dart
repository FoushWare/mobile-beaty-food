import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileState.isLoading
          ? const LoadingWidget(message: 'جاري تحميل الملف الشخصي...')
          : profileState.error != null
              ? _buildErrorWidget(profileState.error!)
              : profileState.profile != null
                  ? _buildProfileContent(profileState)
                  : const Center(
                      child: Text('لا توجد بيانات المستخدم'),
                    ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل الملف الشخصي',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(profileProvider.notifier).loadProfile();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(ProfileState profileState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = profileState.profile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage:
                            profile['profileImage']?.isNotEmpty == true
                                ? NetworkImage(profile['profileImage'])
                                : null,
                        child: profile['profileImage']?.isEmpty != false
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _editProfile(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile['fullName'] ?? 'بدون اسم',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  Text(
                    profile['email'] ?? profile['phone'] ?? '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                          profile['userType'] == 'customer' ? 'عميل' : 'طاهي',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _logout(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.error,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.logout,
                                size: 16,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'تسجيل الخروج',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (profileState.completion != null) ...[
                    const SizedBox(height: 16),
                    _buildProfileCompletion(profileState.completion!),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Profile Actions
          _buildProfileSection(
            context,
            'الإعدادات العامة',
            [
              _buildProfileTile(
                context,
                Icons.edit,
                'تعديل الملف الشخصي',
                () => _editProfile(context),
              ),
              _buildProfileTile(
                context,
                Icons.location_on,
                'إدارة العناوين',
                () => _manageAddresses(context),
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

          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          const SizedBox(height: 16),

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
  }

  Widget _buildProfileCompletion(Map<String, dynamic> completion) {
    final percentage = completion['completionPercentage'] ?? 0;
    final completedFields = completion['completedFields'] ?? 0;
    final totalFields = completion['totalFields'] ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$percentage%',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'اكتمال الملف الشخصي: $completedFields من $totalFields',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
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

  void _editProfile(BuildContext context) {
    // TODO: Navigate to edit profile screen
    _showComingSoon(context);
  }

  void _manageAddresses(BuildContext context) {
    // TODO: Navigate to address management screen
    _showComingSoon(context);
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة قيد التطوير وستكون متاحة قريباً'),
      ),
    );
  }

  void _logout(BuildContext context) {
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
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement proper logout with Riverpod auth provider
              context.go('/welcome');
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
