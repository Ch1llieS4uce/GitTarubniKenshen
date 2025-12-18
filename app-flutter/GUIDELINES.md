# Flutter Development Guidelines

## Project Architecture

### Directory Structure
```
lib/
├── config/          # App configuration
├── features/        # Feature modules (search, home, splash)
├── models/          # Data models
├── providers.dart   # Riverpod provider definitions
├── services/        # Business logic and API calls
└── main.dart        # App entry point
```

---

## 🎯 Code Standards

### 1. Error Handling

**DO:**
```dart
try {
  final res = await dio.get('/api/endpoint');
  
  if (res.statusCode == null || res.statusCode! >= 400) {
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      type: DioExceptionType.badResponse,
      error: 'Failed to fetch data',
    );
  }
  
  final data = res.data?['data'] as List<dynamic>?;
  return data ?? [];
} on DioException {
  rethrow;
} catch (e) {
  throw DioException(
    requestOptions: RequestOptions(path: '/api/endpoint'),
    error: 'Unexpected error: $e',
    type: DioExceptionType.unknown,
  );
}
```

**DON'T:**
```dart
// No error handling
final res = await dio.get('/api/endpoint');
final data = res.data['data'] as List<dynamic>;
return data;

// Swallowing exceptions
try {
  // code
} catch (e) {
  // do nothing
}
```

### 2. Resource Management

**DO:**
```dart
class _MyScreenState extends State<MyScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**DON'T:**
```dart
// Memory leak - controller never disposed
class _MyScreenState extends State<MyScreen> {
  final _controller = TextEditingController();
}
```

### 3. Null Safety

**DO:**
```dart
final data = res.data?['key'] as String?;
final value = data ?? 'default';

final items = (jsonList as List<dynamic>?)
    ?.map((e) => Model.fromJson(e))
    .toList() ?? [];
```

**DON'T:**
```dart
// Unsafe casting and access
final data = res.data['key'] as String;
final items = (jsonList as List<dynamic>).map(...).toList();
```

### 4. const Constructors

**DO:**
```dart
const MyClass({
  required this.title,
  required this.items,
});
```

**DON'T:**
```dart
MyClass({
  required this.title,
  required this.items,
});
```

### 5. State Management with Riverpod

**DO:**
```dart
class MyState {
  final bool loading;
  final String? error;
  final List<Item> items;

  const MyState({
    this.loading = false,
    this.error,
    this.items = const [],
  });

  MyState copyWith({
    bool? loading,
    String? error,
    List<Item>? items,
  }) {
    return MyState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
    );
  }
}

class MyNotifier extends StateNotifier<MyState> {
  final MyService service;
  
  MyNotifier(this.service) : super(const MyState());

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await service.fetch();
      state = state.copyWith(loading: false, items: items);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
```

---

## 🔌 API Integration

### Service Pattern

```dart
class MyService {
  final Dio dio;
  
  MyService(this.dio);

  Future<List<Model>> fetch() async {
    try {
      final res = await dio.get('/api/endpoint');
      
      if (res.statusCode == null || res.statusCode! >= 400) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
          error: 'Server error',
        );
      }

      final data = res.data?['data'] as List<dynamic>?;
      if (data == null) return [];

      return data
          .map((e) => Model.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      rethrow;
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/endpoint'),
        error: 'Unexpected error: $e',
        type: DioExceptionType.unknown,
      );
    }
  }
}
```

### Provider Registration

```dart
final myServiceProvider = Provider<MyService>((ref) {
  return MyService(ref.read(dioProvider));
});

final myNotifierProvider = 
    StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier(ref.read(myServiceProvider));
});
```

---

## 🧪 Testing

### Test Structure

```dart
void main() {
  group('MyService', () {
    late MockDio mockDio;
    late MyService service;

    setUp(() {
      mockDio = MockDio();
      service = MyService(mockDio);
    });

    test('fetch returns list of models', () async {
      // Arrange
      when(mockDio.get(any)).thenAnswer(
        (_) async => Response(
          data: {'data': [...]},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await service.fetch();

      // Assert
      expect(result, isNotEmpty);
      expect(result.first, isA<Model>());
    });

    test('fetch throws on error', () async {
      // Arrange
      when(mockDio.get(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          type: DioExceptionType.unknown,
        ),
      );

      // Act & Assert
      expect(() => service.fetch(), throwsA(isA<DioException>()));
    });
  });
}
```

---

## 📦 Dependencies

Current Dependencies:
- `flutter_riverpod`: ^2.5.1 - State management
- `dio`: ^5.4.3 - HTTP client
- `url_launcher`: ^6.2.6 - URL handling

Future Recommendations:
- `freezed_annotation` + `freezed` - Data models with equality and copyWith
- `json_serializable` - JSON serialization
- `firebase_crashlytics` - Error reporting
- `flutter_test` + `mockito` - Testing utilities

---

## 🚀 Performance Tips

1. **Use `const` constructors** - Reduces widget rebuilds
2. **Dispose resources** - Controllers, streams, listeners
3. **Optimize rebuilds** - Use `ConsumerWidget` instead of watching in build
4. **Cache API responses** - Implement caching layer in services
5. **Lazy load** - Don't fetch data until needed

---

## 🔒 Security Best Practices

1. **Never hardcode API keys** - Use `app_config.dart` with environment variables
2. **Token refresh** - Implement automatic token refresh in API client
3. **HTTPS only** - Always use HTTPS for API calls
4. **Input validation** - Validate user input before API calls
5. **Error messages** - Never expose sensitive info in error messages

---

## 📝 Code Review Checklist

- [ ] No unused imports
- [ ] All resources properly disposed
- [ ] Null safety checks present
- [ ] Error handling implemented
- [ ] const constructors used
- [ ] No hardcoded strings (use constants)
- [ ] No debug prints in production code
- [ ] Linting passes (flutter analyze)
- [ ] Tests pass (flutter test)
- [ ] Code formatted (flutter format)

---

## 🐛 Debugging

### Enable Verbose Logging
```dart
// In main.dart
void main() {
  // Enable HTTP logging
  dio.interceptors.add(
    LoggingInterceptor(),
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### Common Issues

1. **Memory Leaks**: Always dispose controllers and streams
2. **State Not Updating**: Check if using `copyWith` correctly
3. **API Errors**: Check network tab in DevTools, verify API response format
4. **Widget Rebuild Loops**: Use `Future.microtask` in initState for state updates

---

**Last Updated**: December 11, 2025
