import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/role_service.dart';
import '../services/pin_service.dart';
import 'pin_entry_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final RoleService _roleService = RoleService();
  bool _isLoading = false;
  String? _errorMessage;

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.pending:
        return 'Pending Approval';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.loadingAdmin:
        return 'Loading Admin';
      case UserRole.returnsAdmin:
        return 'Returns Admin';
      case UserRole.salesAdmin:
        return 'Sales Admin';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.pending:
        return Colors.grey;
      case UserRole.superAdmin:
        return Colors.purple;
      case UserRole.loadingAdmin:
        return Colors.blue;
      case UserRole.returnsAdmin:
        return Colors.orange;
      case UserRole.salesAdmin:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.pending:
        return Icons.pending;
      case UserRole.superAdmin:
        return Icons.admin_panel_settings;
      case UserRole.loadingAdmin:
        return Icons.local_shipping;
      case UserRole.returnsAdmin:
        return Icons.assignment_return;
      case UserRole.salesAdmin:
        return Icons.analytics;
    }
  }

  Future<void> _updateUserRole(String userId, UserRole newRole) async {
    // Require PIN verification for sensitive operations
    final pinService = Provider.of<PinService>(context, listen: false);
    if (!pinService.requirePinVerification()) {
      // PIN not verified - redirect to PIN entry
      if (mounted) {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const PinEntryScreen(),
          ),
        );
        
        // If PIN entry was cancelled or failed, don't proceed
        if (result != true || !pinService.isPinVerified) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PIN verification required to perform this action'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      await _roleService.updateUserRole(
        userId,
        newRole,
        changedBy: currentUser?.id ?? 'unknown',
        reason: 'Role assigned by Super Admin',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Role updated to ${_getRoleDisplayName(newRole)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to update role: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $_errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRolePicker(String userId, String currentEmail, UserRole currentRole) async {
    // Check PIN verification before showing role picker
    final pinService = Provider.of<PinService>(context, listen: false);
    if (!pinService.isPinVerified) {
      // Show PIN entry screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PinEntryScreen(),
        ),
      );
      
      // If PIN entry was cancelled or failed, don't proceed
      if (result != true || !pinService.isPinVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN verification required to change user roles'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    final newRole = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change User Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User: $currentEmail',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Select new role:'),
            const SizedBox(height: 12),
            ...UserRole.values.where((role) => role != UserRole.pending).map((role) {
              final isSelected = role == currentRole;
              return ListTile(
                leading: Icon(
                  _getRoleIcon(role),
                  color: _getRoleColor(role),
                ),
                title: Text(_getRoleDisplayName(role)),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () => Navigator.of(context).pop(role),
                tileColor: isSelected ? _getRoleColor(role).withOpacity(0.1) : null,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newRole != null && newRole != currentRole) {
      await _updateUserRole(userId, newRole);
    }
  }

  Widget _buildUserCard(Map<String, dynamic> user, AppUser? currentUser) {
    final userId = user['id'] as String;
    final email = user['email'] as String? ?? 'No email';
    final displayName = user['displayName'] as String? ?? 'Unknown User';
    final roleString = user['role'] as String? ?? 'pending';
    final isActive = user['isActive'] as bool? ?? true;
    final isCurrentUser = userId == currentUser?.id;

    UserRole role;
    try {
      role = _roleFromString(roleString);
    } catch (e) {
      role = UserRole.pending;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: role == UserRole.pending ? 1 : 2,
      color: role == UserRole.pending ? Colors.orange.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(role),
          child: Icon(
            _getRoleIcon(role),
            color: Colors.white,
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isCurrentUser ? Colors.purple : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRoleDisplayName(role),
                    style: TextStyle(
                      color: _getRoleColor(role),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Inactive',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                if (isCurrentUser) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: Icon(
                  role == UserRole.pending ? Icons.check_circle : Icons.edit,
                  color: role == UserRole.pending ? Colors.green : null,
                ),
                onPressed: () => _showRolePicker(
                  userId,
                  email,
                  role,
                ),
                tooltip: role == UserRole.pending ? 'Approve user' : 'Change role',
              ),
      ),
    );
  }

  UserRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'pending':
        return UserRole.pending;
      case 'superadmin':
        return UserRole.superAdmin;
      case 'loadingadmin':
        return UserRole.loadingAdmin;
      case 'returnsadmin':
        return UserRole.returnsAdmin;
      case 'salesadmin':
        return UserRole.salesAdmin;
      default:
        return UserRole.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    // Check if user is super admin
    if (currentUser?.role != UserRole.superAdmin) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
        ),
        body: const Center(
          child: Text(
            'Only Super Admins can access user management.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _roleService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No users found.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final users = snapshot.data!;
          
          // Separate pending and active users
          final pendingUsers = users.where((u) {
            final roleString = u['role'] as String? ?? 'pending';
            return roleString.toLowerCase() == 'pending';
          }).toList();
          
          final activeUsers = users.where((u) {
            final roleString = u['role'] as String? ?? 'pending';
            return roleString.toLowerCase() != 'pending';
          }).toList();

          return Column(
            children: [
              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.red.shade100,
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Pending Users Section
                    if (pendingUsers.isNotEmpty) ...[
                      const Text(
                        'Pending Approval',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pendingUsers.map((user) => _buildUserCard(user, currentUser)),
                      const SizedBox(height: 24),
                    ],
                    
                    // Active Users Section
                    if (activeUsers.isNotEmpty) ...[
                      const Text(
                        'Active Users',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...activeUsers.map((user) => _buildUserCard(user, currentUser)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
