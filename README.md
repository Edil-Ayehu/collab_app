# Collab App

A collaborative task management Flutter application that enables teams to work together efficiently by managing projects, tasks, and team member roles.

## 🌟 Features

### Project Management
- Create and manage multiple projects
- Assign project roles (creator, admin, member, viewer)
- Track project status and progress
- Customizable project descriptions and settings

### Task Management
- Create, edit, and delete tasks
- Assign tasks to team members
- Set task priorities and due dates
- Track task status (Todo, In Progress, Completed, etc.)
- Task limit monitoring per team member

### Team Collaboration
- Member management with role-based permissions
- Real-time updates on task changes
- Comment system with @mentions
- Track member contributions and availability

### User Management
- User authentication via Firebase
- Role-based access control
- Customizable user profiles
- Task load balancing

## 🛠 Technical Stack

- **Frontend Framework**: Flutter
- **Backend Services**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **State Management**: GetX
- **Platform Support**: iOS, Android, Web, macOS, Windows, Linux

## 📋 Prerequisites

- Flutter SDK (Latest stable version)
- Dart SDK
- Firebase account and project setup
- iOS/Android development environment setup

## 🚀 Getting Started

1. **Clone the repository**

```
git clone https://github.com/your-username/collab_app.git
```

```
cd collab_app
```

2. **Install dependencies**

```
flutter pub get
```

3. **Configure Firebase**
- Create a new Firebase project
- Add your Firebase configuration files:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS
  - Configure web setup in `index.html`

4. **Run the application**

```
flutter run
```

## 📱 Supported Platforms

- iOS
- Android
- Web
- macOS
- Windows
- Linux

## 🏗 Project Structure

```
lib/
├── app/
│   ├── data/
│   │   ├── models/
│   │   └── services/
│   ├── modules/
│   │   ├── projects/
│   │   ├── tasks/
│   │   └── users/
│   └── helpers/
├── firebase_options.dart
└── main.dart
```

## 🔐 Security

- Role-based access control
- Secure Firebase rules
- User authentication
- Data validation

## 🔄 State Management

The application uses GetX for state management, providing:
- Reactive state management
- Dependency injection
- Route management
- Simple and efficient code structure

## 🎯 Key Components

### Task Details Controller
- Manages task-related operations
- Handles comments and mentions
- Controls task assignments
- Manages task status updates

### Project Details Controller
- Manages project members
- Controls project settings
- Handles task creation within projects
- Manages project roles and permissions

## 📝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details

## 👥 Authors

- Your Name - *Initial work* - [YourGithub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- GetX team for state management solutions
```

