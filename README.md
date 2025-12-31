# Personal Expense Tracker

A Flutter-based mobile application to track personal expenses, manage income, and analyze spending habits with a clean, responsive UI.

---

## 📱 Overview

**Personal Expense Tracker** helps users:
- Record daily expenses
- Categorize spending
- Track total income, expenses, and remaining balance
- View spending history
- Manage profile and update password

The app uses **Supabase Authentication** for secure login and **Riverpod** for state management.

---

## 🧩 Project Details

- **Project Name**: personal_expense_tracker
- **Version**: 1.0.0
- **Platform**: Android & iOS
- **Status**: Completed (Assessment Submission)
- **Last Updated**: 2025

---

## 🛠️ Technical Stack

- **Framework**: Flutter (3.x)
- **Language**: Dart (3.x)
- **State Management**: Riverpod
- **Backend / Auth**: Supabase
- **Database**: Supabase PostgreSQL
- **Architecture**: Feature-based architecture
- **UI Framework**: Material Design 3
- **Routing**: GoRouter
- **Serialization**: json_serializable
- **Code Generation**: build_runner

---

## 📦 Dependencies (Key)

- flutter_riverpod
- supabase_flutter
- go_router
- intl
- json_annotation

---

## 📁 Project Structure
```
lib/
├── main.dart
├── app.dart
├── router/
│ └── app_router.dart
├── auth/
│ └── auth_provider.dart
├── expenses/
│ ├── expense_model.dart
│ ├── expense_model.g.dart
│ └── expense_provider.dart
├── ui/
│ ├── login_page.dart
│ ├── signup_page.dart
│ ├── verify_email_page.dart
│ ├── home_page.dart
│ ├── add_expense_page.dart
│ ├── edit_expense_page.dart
│ ├── wallet_page.dart
│ ├── profile_page.dart
│ ├── statistics_page.dart
│ └── widgets/
│   ├── income_provider.dart
│   ├── gradient_header.dart
│   ├── bottom_nav_bar.dart
│   ├── balance_card.dart
│   └── toggle_chip.dart
└── shared/
  └── constant.dart
```
---

## 🔐 Authentication Flow

1. User signs up with email & password
2. Verification email is sent (Supabase)
3. User verifies email
4. User logs in
5. Authenticated user accesses app features

---

## 💼 Core Features

### ✅ Expense Management
- Add expense with name, amount, category, and date
- View expense history
- Edit existing expenses

### ✅ Wallet
- Set and update total income
- View total spent and remaining balance
- Spending history list

### ✅ Statistics
- Filter expenses by Day / Week / Month / Year
- Toggle between Income and Expense views

### ✅ Profile
- View user email
- Update monthly income
- Update account password
- Logout

---

## 📱 Responsiveness & UI

- Fully responsive for all mobile screen sizes
- Keyboard-safe layouts
- Dark mode compatible
- Pixel-aligned with provided Figma design

---

## 🚀 Installation & Setup

### Prerequisites
- Flutter SDK 3.x
- Dart SDK 3.x
- Android Studio / VS Code
- Android Emulator or physical device

### Steps

```bash
git clone https://github.com/codingguna/personal_expense_tracker.git
cd personal_expense_tracker
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```
