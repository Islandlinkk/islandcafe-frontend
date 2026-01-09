# ☕ Island Cafe

A Flutter mobile application for ordering coffee and beverages from Island Cafe.

## 📱 Features

- **Authentication** - Email/Password and Google Sign-In
- **Product Browsing** - Browse menu with categories
- **Product Customization** - Select size, sugar level, ice level, and extra shots
- **Shopping Cart** - Add, update, and remove items
- **Order Management** - Place orders and view order history
- **User Profile** - Manage profile and settings
- **Vouchers** - Apply discount vouchers
- **Favorites** - Save favorite products
- **Dark/Light Theme** - Toggle between themes

## 🛠️ Tech Stack

- **Flutter** - Cross-platform framework
- **Riverpod** - State management
- **Firebase** - Authentication, Firestore, Storage
- **Hive** - Local storage
- **GoRouter** - Navigation

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/Islandlinkk/islandcafe-frontend.git
cd islandcafe-frontend
```

2. Install dependencies
```bash
flutter pub get
```

3. Set up Firebase
   - Create a Firebase project
   - Enable Authentication, Firestore, and Storage
   - Run `flutterfire configure` to generate `firebase_options.dart`
   - Deploy Firestore rules: `firebase deploy --only firestore:rules`

4. Create `.env` file in the root directory

5. Generate code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

6. Run the app
```bash
flutter run
```

## 📁 Project Structure

```
lib/
├── core/                  # Core functionality
│   ├── config/           # API configuration
│   ├── route/            # Routing configuration
│   └── widgets/          # Shared widgets
├── feature/               # Feature modules
│   ├── account/          # User account management
│   ├── announcement/     # Announcements
│   ├── auth/             # Authentication
│   ├── cart/             # Shopping cart
│   ├── checkout/         # Checkout flow
│   ├── history/          # Order history
│   ├── home/             # Home screen
│   ├── menu/             # Menu browsing
│   ├── product/          # Product details
│   ├── profile/          # User profile
│   ├── theme/            # App theming
│   └── voucher/          # Voucher system
├── root/                  # Root navigation
├── firebase_options.dart  # Firebase configuration
├── hive_registrar.g.dart # Hive adapters
├── main.dart             # App entry point
└── main_widget.dart      # Main widget setup
```

## 🔗 Related Links

- [Backend Dashboard](https://coffee-shop-system-two.vercel.app/dashboard/order)
- [Cart Management Guide](CART_MANAGEMENT_GUIDE.md)
- [Firestore Setup Guide](FIRESTORE_SETUP.md)

---

**School Project - Royal University of Phnom Penh - Information Technology Engineering - MADII Y4**
