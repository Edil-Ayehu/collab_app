import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/projects/bindings/project_binding.dart';
import '../modules/projects/views/project_view.dart';
import '../modules/tasks/bindings/task_binding.dart';
import '../modules/tasks/views/task_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.auth;

  static final routes = [
    GetPage(
      name: Routes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.projects,
      page: () => const ProjectView(),
      binding: ProjectBinding(),
    ),
    GetPage(
      name: Routes.tasks,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
  ];
} 