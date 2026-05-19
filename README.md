# Inventory Management System — Mobile App

Flutter companion app for the Laravel inventory API.

## Project structure (`lib/`)

```
lib/
├── core/
│   ├── constants/     # AppColors, text styles, API constants
│   ├── network/       # ApiClient (HTTP layer)
│   ├── router/        # AppRoutes & AppRouter
│   ├── storage/       # TokenStorage (SharedPreferences)
│   ├── theme/         # AppTheme
│   └── utils/         # AppToast
├── models/
├── providers/
├── screens/
├── services/          # ApiService (business API calls)
├── widgets/
├── app.dart           # MaterialApp + providers
└── main.dart          # Entry point
```

## Run

1. Copy `.env.example` to `.env` and set `API_BASE_URL`.
2. `flutter pub get`
3. `flutter run`
