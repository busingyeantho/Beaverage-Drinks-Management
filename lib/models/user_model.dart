enum UserRole {
  pending, // New users awaiting approval
  superAdmin,
  loadingAdmin,
  returnsAdmin,
  salesAdmin,
}

class AppUser {
  final String id;
  final String email;
  final UserRole role;
  final String? department;
  final String displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.department,
    required this.displayName,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      role: _roleFromString(json['role'] as String? ?? 'pending'),
      department: json['department'] as String?,
      displayName: json['displayName'] as String? ?? 'Guest',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.toString().split('.').last,
      'department': department,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  static UserRole _roleFromString(String role) {
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
        return UserRole.pending; // Default to pending - requires approval
    }
  }

  bool get canApproveData => role == UserRole.superAdmin;
  
  bool get isPending => role == UserRole.pending;
  
  bool get isActive => role != UserRole.pending;
  
  bool canEditLoadingData() => [
        UserRole.superAdmin,
        UserRole.loadingAdmin,
      ].contains(role);

  bool canEditReturnsData() => [
        UserRole.superAdmin,
        UserRole.returnsAdmin,
      ].contains(role);

  bool canEditSalesData() => [
        UserRole.superAdmin,
        UserRole.salesAdmin,
      ].contains(role);
}
