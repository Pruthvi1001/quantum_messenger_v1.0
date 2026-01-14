# Quantum Messenger 🌐

<p align="center">
  <img src="assets/icon/app_icon.png" alt="Quantum Messenger Logo" width="120"/>
</p>

<p align="center">
  <strong>Secure, Peer-to-Peer Messaging for Disaster Scenarios</strong>
</p>

<p align="center">
  <a href="https://github.com/Pruthvi1001/quantum_messenger_v1.0/releases/latest">
    <img src="https://img.shields.io/badge/Download-APK-orange?style=for-the-badge&logo=android" alt="Download APK"/>
  </a>
</p>

---

## 📖 Overview

**Quantum Messenger** is a secure, offline-capable messaging application designed for peer-to-peer communication. Built with Flutter, it enables direct device-to-device messaging using nearby connections technology — perfect for scenarios where traditional internet infrastructure is unavailable.

## ✨ Features

- 🔒 **End-to-End Encryption** — Messages secured with PointyCastle cryptographic library
- 📡 **P2P Communication** — Direct device-to-device messaging via Nearby Connections
- 🌍 **Offline-First** — Works without internet connectivity
- 👥 **Contact Management** — Organize and manage your trusted contacts
- 🛡️ **Policy Engine** — Configurable security and privacy policies
- 🎨 **Modern UI** — Beautiful disaster-themed glassmorphism design
- 📱 **Cross-Platform** — Android, iOS, macOS, Windows, Linux, and Web

## 📱 Screenshots

| Discovery | Contacts | Chat | Policy | Profile |
|-----------|----------|------|--------|---------|
| Discover nearby peers | Manage contacts | Secure messaging | Security settings | User profile |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.9.2`
- Android Studio / Xcode (for mobile development)
- A physical device (nearby connections requires real hardware)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Pruthvi1001/quantum_messenger_v1.0.git
   cd quantum_messenger_v1.0
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📦 Download

Download the latest production APK from the [Releases](https://github.com/Pruthvi1001/quantum_messenger_v1.0/releases/latest) page.

## 🏗️ Architecture

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── contact.dart
│   ├── conversation.dart
│   ├── message.dart
│   └── peer.dart
├── services/                 # Business logic
│   ├── chat_service.dart
│   ├── communication_service.dart
│   ├── contacts_service.dart
│   ├── crypto_service.dart
│   └── policy_engine.dart
├── state/                    # State management
│   └── app_state.dart
└── ui/                       # User interface
    ├── colors.dart
    └── screens/
        ├── chat_screen.dart
        ├── contacts_screen.dart
        ├── discovery_screen.dart
        ├── policy_screen.dart
        └── profile_screen.dart
```

## 🔧 Dependencies

| Package | Purpose |
|---------|---------|
| `nearby_connections` | P2P device communication |
| `pointycastle` | Cryptographic operations |
| `provider` | State management |
| `permission_handler` | Runtime permissions |
| `device_info_plus` | Device information |
| `shared_preferences` | Local storage |

## 🔐 Security

Quantum Messenger implements:
- **AES encryption** for message content
- **RSA key exchange** for secure key sharing
- **Local key storage** using secure preferences
- **No central server** — all communication is peer-to-peer

## 📄 License

This project is private and proprietary.

## 👨‍💻 Author

**Pruthvi** - [GitHub](https://github.com/Pruthvi1001)

---

<p align="center">
  Made with ❤️ using Flutter
</p>
</CodeContent>
<parameter name="EmptyFile">false
