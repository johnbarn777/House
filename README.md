---

# 🏡 **House**

Welcome to House, a cross‑platform React Native app for keeping shared living spaces in sync. The project leverages Firebase for authentication and real‑time data so house members can collaborate effortlessly on household tasks.

---

## 🌟 Features

- **Secure Authentication** – email/password and Google sign in powered by Firebase Auth.
- **House Management** – create a house or join an existing one with a six‑digit code.
- **Chore Tracking** – add chores, edit them and assign them to house members, with optional automatic assignments.
- **Profile Controls** – update your name, phone number, profile photo and even change your email or password.
- **Real‑time Updates** – all data is stored in Firestore, ensuring everyone sees the latest changes immediately.
- **Cross‑platform** – built with React Native, runs on both iOS and Android.

---

## 🚀 Getting Started

### Prerequisites

- **Node.js**: v18 or higher
- **React Native**: v0.79.1 or higher
- **Firebase**: Set up your Firebase project and get the configuration details.

### Installation

Clone the repository and install dependencies.

### Configuration

Create a Firebase project and copy your configuration values into the app before running it. The `@react-native-firebase/*` packages are already included.

### Install Dependencies

Requires Yarn 4.x. If you are using Node.js 18+, enable Corepack to manage Yarn versions:
```bash
corepack enable
```
```bash
yarn install
```


### Run the App

For iOS:
Set-up CocoaPods first.

```bash
pod install && npx react-native run-ios
```

For Android:

```bash
npx react-native run-android
```

## 📚 Documentation

- **[Firebase Setup Guide](https://firebase.google.com/docs/web/setup)**
- **[React Native Documentation](https://reactnative.dev/docs/getting-started)**

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Great houses are just the beginning—enjoy effortless shared living with House. 🌟🏡**

---
