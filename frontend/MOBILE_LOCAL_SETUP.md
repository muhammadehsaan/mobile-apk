# Mobile Local Setup (Android + iOS)

## Module 1: API Connectivity (Local Backend)

This project now picks API URL by platform:

- Android emulator default: `http://10.0.2.2:8000/api/v1`
- iOS simulator default: `http://127.0.0.1:8000/api/v1`
- Desktop default: `http://127.0.0.1:8000/api/v1`

You can override for physical devices with `--dart-define`:

```bash
flutter run -d <device-id> --dart-define=API_BASE_URL=http://192.168.1.50:8000/api/v1
```

Replace `192.168.1.50` with your PC LAN IP.

## Module 2: Backend for Mobile Access

Run Django on all interfaces:

```bash
python manage.py runserver 0.0.0.0:8000
```

Backend now allows all hosts in debug mode (`DEBUG=True`), so local phone/emulator can connect.

## Module 3: Android Platform Folder

If `frontend/android` is missing, generate it:

```bash
flutter create . --platforms=android,ios
```

Then:

```bash
flutter pub get
flutter devices
flutter run -d android
```

## Quick Test Checklist

1. Backend reachable from phone browser: `http://<PC-LAN-IP>:8000/admin/`
2. App login works on mobile.
3. Image URLs (`/media/...`) open correctly on mobile screens.
