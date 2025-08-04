import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final Widget? unauthorizedChild;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    this.unauthorizedChild,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const _UnauthorizedView();
    }

    if (!allowedRoles.contains(user.role)) {
      return unauthorizedChild ?? const _UnauthorizedView();
    }

    return child;
  }
}

class _UnauthorizedView extends StatelessWidget {
  const _UnauthorizedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'You do not have permission to access this page.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Helper extension for cleaner role-based navigation
extension RoleNavigation on BuildContext {
  bool hasRole(UserRole role) {
    final user = read<AuthService>().currentUser;
    return user?.role == role;
  }

  bool hasAnyRole(List<UserRole> roles) {
    final user = read<AuthService>().currentUser;
    return user != null && roles.contains(user.role);
  }
}
