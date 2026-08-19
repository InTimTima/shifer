# Shifer

Flutter-приложение: шифратор-дешифратор (зеркальный, Цезарь, Цезарь+ключевое слово, транспозиция, подстановка, кодирование).

## Запуск

Flutter в PATH: `C:\Users\user\flutter\bin`.

```bash
flutter pub get
flutter run -d chrome      # web
flutter run -d windows      # windows
flutter run                 # выбор устройства
```

## Структура

- `lib/ciphers/` — реализации шифров, `cipher_factory.dart` — точка входа
- `lib/screens/` — экраны (main_shell -> home_screen / cipher_screen / detector_screen / custom_cipher_screen)
- `lib/models/` — модели: `alphabet.dart`, `cipher_info.dart`, `custom_cipher.dart`, `space_mode.dart`
- `lib/services/` — `app_settings.dart` (shared_preferences), `cipher_detector.dart`
- `lib/l10n/` — локализация (ru/en), `app_strings.dart` + `cipher_texts.dart`
- `lib/widgets/` — переиспользуемые виджеты

## Анализ и линтеры

```bash
flutter analyze
```

Используется `flutter_lints` (см. `analysis_options.yaml`). Нет CI.

## Ключевые особенности

- Алфавиты: русский, английский, немецкий + пользовательские шаблоны
- Язык интерфейса: русский / English
- Карусель шифров на главном экране
- Мгновенное шифрование/дешифрование в обе стороны
