# Flappy Bird (Godot 4.3)

Простой Flappy Bird для Android (портрет, 720×1280), подготовлен к публикации в RuStore.

## Сборка APK

Требуется:

- Godot 4.3 stable (`/opt/godot/Godot_v4.3-stable_linux.x86_64` или `$GODOT_BIN`)
- Android SDK (`~/Android/sdk`, переменные `ANDROID_HOME`/`ANDROID_SDK_ROOT`)
- Release-keystore `~/.android/flappy_release.jks` и файл ключей `~/.android/flappy_release.env`:

  ```
  export GODOT_ANDROID_KEYSTORE_RELEASE_PATH=/home/USER/.android/flappy_release.jks
  export GODOT_ANDROID_KEYSTORE_RELEASE_USER=flappy
  export GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD=СЕКРЕТ
  ```

  > Креды подписи **не** хранятся в репозитории.

Сборка (release + debug):

```bash
./tools/build-apk.sh
```

Результат:

- `build/android/flappy_bird.apk` — release (для RuStore)
- `build/android/flappy_bird_debug.apk` — debug (установка на устройство для проверки)

## Параметры публикации

| Параметр | Значение |
|---|---|
| Пакет | `com.miroden4ik.flappybird` |
| Версия | `0.1.0` (versionCode 1) |
| Ориентация | Портретная |
| Минимальный Android | API 21 (Lollipop) |
| Целевой Android | API 34 (Android 14) |
| ABIs | armeabi-v7a, arm64-v8a |
| Рендер | GL Compatibility (мобильный) |

## Управление

- Тап по экрану — прыжок
- Системная кнопка «Назад» или сворачивание приложения — пауза
- Кнопка `M` (клавиатура) — мьют

## Структура

- `scenes/main.tscn` — главная сцена (включает `PauseOverlay`)
- `scripts/gamestate.gd` — autoload: состояние, пауза при сворачивании
- `scripts/pause_overlay.gd` — оверлей паузы
- `tools/generate_icons.py` — генерация иконок (`assets/icons/`)
- `tools/build-apk.sh` — сборка APK