# Architecture Guide

PulseTrade follows **Clean Architecture** principles with clear separation of concerns.

## 📐 Clean Architecture Layers

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │  ← UI, Widgets, State Management
├─────────────────────────────────────────┤
│         Domain Layer                    │  ← Business Logic, Entities, Use Cases
├─────────────────────────────────────────┤
│         Data Layer                      │  ← Repositories, Data Sources, Models
└─────────────────────────────────────────┘
```

## 🏗️ Folder Structure

```
lib/
├── core/                          # Shared/Core functionality
│   ├── config/                    # App configuration
│   ├── error/                     # Error handling (Failure classes)
│   ├── localization/              # i18n setup
│   ├── network/                   # HTTP client, network info
│   ├── presentation/              # Shared widgets
│   │   └── widgets/
│   │       ├── app_button.dart
│   │       ├── app_text_field.dart
│   │       └── google_button.dart
│   ├── router/                    # Navigation (GoRouter)
│   ├── storage/                   # Local storage
│   │   ├── cache/                 # Hive cache
│   │   ├── preferences/           # SharedPreferences
│   │   └── secure/                # Secure storage
│   ├── theme/                     # 🎨 Design System
│   │   ├── app_colors.dart        # Colors, spacing, radius
│   │   ├── app_theme.dart         # Theme configuration
│   │   └── typography.dart        # Text styles
│   ├── usecase/                   # Base UseCase class
│   └── utils/                     # Utilities
│
└── features/                      # Feature modules
    ├── auth/                      # Authentication feature
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_local_data_source.dart
    │   │   │   └── auth_remote_data_source.dart
    │   │   ├── models/            # Data models (JSON)
    │   │   │   └── user_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/          # Business entities
    │   │   │   └── user.dart
    │   │   ├── repositories/      # Repository contracts
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/          # Business logic
    │   │       ├── login.dart
    │   │       ├── logout.dart
    │   │       └── register.dart
    │   └── presentation/
    │       ├── providers/         # Riverpod providers
    │       │   └── auth_providers.dart
    │       ├── views/             # Screens
    │       │   ├── login_screen.dart
    │       │   └── register_screen.dart
    │       └── widgets/           # Feature-specific widgets
    │           └── or_divider.dart
    │
    ├── home/                      # Home feature
    ├── settings/                  # Settings feature
    └── survey/                    # Survey feature
```

## 🔄 Data Flow

```
User Interaction
      ↓
  Widget/View
      ↓
  Provider (State Management)
      ↓
  Use Case (Business Logic)
      ↓
  Repository Interface (Domain)
      ↓
  Repository Implementation (Data)
      ↓
  Data Source (Remote/Local)
      ↓
  API/Database
```

## 📦 Layer Responsibilities

### 1. **Presentation Layer** (`presentation/`)
- **Responsibility**: UI rendering, user interactions, state management
- **Components**:
  - `views/`: Full screen widgets
  - `widgets/`: Reusable UI components
  - `providers/`: Riverpod state management
- **Dependencies**: Can depend on Domain layer
- **Example**:
  ```dart
  class LoginScreen extends ConsumerStatefulWidget {
    // Displays UI and handles user interaction
    // Uses providers to access business logic
  }
  ```

### 2. **Domain Layer** (`domain/`)
- **Responsibility**: Business logic, independent of frameworks
- **Components**:
  - `entities/`: Core business objects (pure Dart classes)
  - `repositories/`: Abstract repository interfaces
  - `usecases/`: Business logic operations
- **Dependencies**: No dependencies on other layers (pure Dart)
- **Example**:
  ```dart
  // Entity
  class User {
    final String id;
    final String email;
    final String name;
  }
  
  // Use Case
  class Login extends UseCase<User, LoginParams> {
    @override
    Future<Either<Failure, User>> call(LoginParams params) {
      return repository.login(params.email, params.password);
    }
  }
  ```

### 3. **Data Layer** (`data/`)
- **Responsibility**: Data access and persistence
- **Components**:
  - `models/`: Data transfer objects (with JSON serialization)
  - `repositories/`: Repository implementations
  - `datasources/`: API clients, local storage
- **Dependencies**: Implements Domain layer contracts
- **Example**:
  ```dart
  // Model (extends Entity)
  class UserModel extends User {
    factory UserModel.fromJson(Map<String, dynamic> json) {...}
    Map<String, dynamic> toJson() {...}
  }
  
  // Repository Implementation
  class AuthRepositoryImpl implements AuthRepository {
    final AuthRemoteDataSource remoteDataSource;
    final AuthLocalDataSource localDataSource;
    
    @override
    Future<Either<Failure, User>> login(String email, String password) {
      // Fetch from API, cache locally, return result
    }
  }
  ```

## 🎯 Key Principles

### Dependency Rule
**Inner layers should NOT depend on outer layers**

```
✅ Presentation → Domain (OK)
✅ Data → Domain (OK)
❌ Domain → Presentation (NOT OK)
❌ Domain → Data (NOT OK)
```

### Separation of Concerns
- **Entities**: Business objects (no dependencies)
- **Use Cases**: Single responsibility business operations
- **Repositories**: Abstract data access (interface in domain, implementation in data)
- **Providers**: State management and dependency injection

### Error Handling
```dart
// Use Either type from fpdart for error handling
Either<Failure, Success>

// Example
Future<Either<Failure, User>> login(String email, String password) async {
  try {
    final user = await remoteDataSource.login(email, password);
    return Right(user);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
```

## 🛠️ Core Technologies

| Technology | Purpose |
|------------|---------|
| **Flutter** | UI framework |
| **Riverpod** | State management & DI |
| **GoRouter** | Navigation |
| **Dio** | HTTP client |
| **Hive** | Local database |
| **SharedPreferences** | Simple key-value storage |
| **flutter_secure_storage** | Secure storage (tokens) |
| **fpdart** | Functional programming (Either type) |
| **freezed** | Code generation (unions, copyWith) |
| **json_serializable** | JSON serialization |

## 📝 Naming Conventions

### Files
- **Snake case**: `user_model.dart`, `auth_repository.dart`
- **Descriptive names**: Indicate purpose and layer

### Classes
- **PascalCase**: `UserModel`, `AuthRepository`, `LoginScreen`
- **Suffixes**:
  - `Screen`: Full screen widgets (`LoginScreen`)
  - `Widget`: Reusable widgets (`AppButton`)
  - `Provider`: Riverpod providers (`authProvider`)
  - `Model`: Data models (`UserModel`)
  - `Repository`: Repository classes (`AuthRepository`)
  - `UseCase`: Use case classes (`Login`, `Logout`)

### Variables
- **camelCase**: `userName`, `isLoading`, `emailController`
- **Private**: Prefix with underscore (`_emailController`)

## 🚀 Creating a New Feature

1. **Create feature folder** in `lib/features/`
2. **Add layers**:
   ```
   features/my_feature/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   └── presentation/
       ├── providers/
       ├── views/
       └── widgets/
   ```
3. **Start with domain** (entities, repository interface, use cases)
4. **Implement data** (models, data sources, repository)
5. **Build presentation** (providers, views, widgets)

## 🔍 Example: Auth Feature Flow

```dart
// 1. User taps Login button
// LoginScreen (Presentation)
onPressed: () => ref.read(authControllerProvider.notifier).login(email, password)

// 2. Provider calls use case
// AuthController (Presentation)
Future<void> login(String email, String password) async {
  state = const AsyncLoading();
  final result = await _loginUseCase(LoginParams(email, password));
  // Handle result...
}

// 3. Use case calls repository
// Login (Domain)
Future<Either<Failure, User>> call(LoginParams params) {
  return _repository.login(params.email, params.password);
}

// 4. Repository fetches data
// AuthRepositoryImpl (Data)
Future<Either<Failure, User>> login(String email, String password) async {
  final userModel = await _remoteDataSource.login(email, password);
  await _localDataSource.cacheUser(userModel);
  return Right(userModel);
}

// 5. Data source makes API call
// AuthRemoteDataSource (Data)
Future<UserModel> login(String email, String password) async {
  final response = await _dio.post('/auth/login', data: {...});
  return UserModel.fromJson(response.data);
}
```

## 📚 Additional Resources

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://github.com/ResoCoder/flutter-tdd-clean-architecture-course)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

---

**Tip**: Always think "Which layer does this belong to?" before adding new code.

