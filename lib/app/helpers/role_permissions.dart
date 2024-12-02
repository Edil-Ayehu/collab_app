class RolePermissions {
  static const Map<String, Map<String, bool>> projectPermissions = {
    'creator': {
      'edit_project': true,
      'delete_project': true,
      'manage_members': true,
      'create_tasks': true,
      'edit_tasks': true,
      'delete_tasks': true,
      'assign_tasks': true,
      'comment': true,
      'view_all': true,
       'change_status': true,  // Add this line
    },
    'admin': {
      'edit_project': true,
      'delete_project': false,
      'manage_members': true,
      'create_tasks': true,
      'edit_tasks': true,
      'delete_tasks': true,
      'assign_tasks': true,
      'comment': true,
      'view_all': true,
       'change_status': true,  // Add this line
    },
    'member': {
      'edit_project': false,
      'delete_project': false,
      'manage_members': false,
      'create_tasks': true,
      'edit_tasks': true,
      'delete_tasks': false,
      'assign_tasks': false,
      'comment': true,
      'view_all': true,
       'change_status': false,  // Add this line
    },
    'viewer': {
      'edit_project': false,
      'delete_project': false,
      'manage_members': false,
      'create_tasks': false,
      'edit_tasks': false,
      'delete_tasks': false,
      'assign_tasks': false,
      'comment': true,
      'view_all': true,
       'change_status': false,  // Add this line
    },
  };

  static bool hasPermission(String role, String permission) {
    return projectPermissions[role]?[permission] ?? false;
  }
} 