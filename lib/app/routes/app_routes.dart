part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  
  static const auth = '/auth';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const projects = '/projects';
  static const projectDetails = '/project/:id';
  static const tasks = '/tasks';
  static const taskDetails = '/task/:id';
  static const settings = '/settings';
  static const profile = '/profile';
} 