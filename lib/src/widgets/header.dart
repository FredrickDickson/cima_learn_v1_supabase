import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/enhanced_auth_service.dart';
import 'cart_icon_widget.dart';
import '../utils/responsive.dart';
import '../screens/privacy_policy_page.dart';
import '../screens/terms_of_service_page.dart';
import '../screens/profile_page.dart';
import '../screens/progress_dashboard.dart';
import 'theme_switcher_widget.dart';

class Header extends StatelessWidget {
  final bool isMobile;

  const Header({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: AssetImage('assets/images/cima_logo.png'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                color: const Color(0xFFB71C1C),
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CIMA Learn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                Text(
                  'Dispute Resolution Training',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          if (isMobile) ...[
            const CartIconWidget(),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.menu, size: 24),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ]
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CartIconWidget(),
                const SizedBox(width: 8),
                ThemeSwitcherWidget(showLabel: false),
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    switch (value) {
                      case 'profile':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProfilePage()),
                        );
                        break;
                      case 'progress':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProgressDashboard()),
                        );
                        break;
                      case 'login':
                        Navigator.pushNamed(context, '/login');
                        break;
                      case 'privacy':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                        );
                        break;
                      case 'terms':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                        );
                        break;
                      case 'admin':
                        Navigator.pushNamed(context, '/admin');
                        break;
                      case 'instructor':
                        Navigator.pushNamed(context, '/instructor');
                        break;
                      case 'logout':
                        Provider.of<EnhancedAuthService>(context, listen: false).signOut();
                        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return Consumer<EnhancedAuthService>(
                      builder: (context, auth, child) {
                        List<PopupMenuItem<String>> items = [];

                        if (auth.isAuthenticated) {
                          // Authenticated user menu items
                          items.addAll([
                            const PopupMenuItem<String>(
                              value: 'profile',
                              child: ListTile(
                                leading: Icon(Icons.person),
                                title: Text('My Profile'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'progress',
                              child: ListTile(
                                leading: Icon(Icons.trending_up),
                                title: Text('Learning Progress'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ]);

                          // Role-specific menu items
                          if (auth.canCreateCourses()) {
                            items.add(
                              const PopupMenuItem<String>(
                                value: 'instructor',
                                child: ListTile(
                                  leading: Icon(Icons.school),
                                  title: Text('Instructor Dashboard'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            );
                          }

                          if (auth.hasAdminAccess()) {
                            items.add(
                              const PopupMenuItem<String>(
                                value: 'admin',
                                child: ListTile(
                                  leading: Icon(Icons.admin_panel_settings),
                                  title: Text('Admin Panel'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            );
                          }

                          // Logout option for authenticated users
                          items.add(
                            const PopupMenuItem<String>(
                              value: 'logout',
                              child: ListTile(
                                leading: Icon(Icons.logout, color: Colors.red),
                                title: Text('Sign Out', style: TextStyle(color: Colors.red)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        } else {
                          // Non-authenticated user menu items
                          items.add(
                            const PopupMenuItem<String>(
                              value: 'login',
                              child: ListTile(
                                leading: Icon(Icons.login),
                                title: Text('Sign In'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          );
                        }

                        // Common menu items for all users
                        items.addAll([
                          const PopupMenuItem<String>(
                            value: 'privacy',
                            child: ListTile(
                              leading: Icon(Icons.privacy_tip),
                              title: Text('Privacy Policy'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'terms',
                            child: ListTile(
                              leading: Icon(Icons.description),
                              title: Text('Terms of Service'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ]);

                        return items;
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFB71C1C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Menu',
                          style: TextStyle(
                            color: Color(0xFFB71C1C),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, color: Color(0xFFB71C1C)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}