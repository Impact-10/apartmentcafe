# FoodVendor - Apartment Café Ordering System

A complete food ordering system with web admin panel and Flutter mobile app, powered by Firebase Realtime Database.

## 🏗️ Project Structure

```
FoodVendor/
├── food/                    # Web Application (React + Vite)
│   ├── src/
│   │   ├── components/     # React components
│   │   ├── hooks/          # Custom hooks
│   │   ├── lib/            # Firebase & utilities
│   │   └── styles.css
│   ├── package.json
│   └── .env.local.example
│
└── flutter-app/            # Mobile Application (Flutter)
    ├── lib/
    │   ├── models/
    │   ├── providers/
    │   ├── screens/
    │   ├── services/
    │   └── widgets/
    └── pubspec.yaml
```

## 🚀 Features

### Web Application (Admin Panel)
- **Admin Authentication** - Secure login for restaurant staff
- **Menu Management** - Create, edit, and organize menu items
- **Active Menu Publishing** - Control which items are visible to customers
- **Schedule Management** - Set opening/closing times
- **Order Management** - View and process incoming orders
- **Real-time Updates** - Instant sync with Firebase RTDB
- **Offline Support** - Queue changes when offline, sync when back online

### Mobile Application (Customer App)
- **Browse Menu** - View available items by meal type (breakfast, lunch, snack, dinner)
- **Shopping Cart** - Add items and manage quantities
- **Place Orders** - Submit orders with delivery details
- **Schedule Aware** - Shows shop status based on opening hours
- **Offline Persistence** - Works without internet, syncs later
- **Connection Status** - Visual indicators for offline mode

## 📋 Prerequisites

- **Node.js** (v18 or higher)
- **Flutter** (v3.0 or higher)
- **Firebase Project** with Realtime Database enabled
- **Android Studio** / **Xcode** for mobile development

## 🔧 Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/Impact-10/FoodVendor.git
cd FoodVendor
```

### 2. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Realtime Database**
3. Enable **Authentication** (Email/Password)
4. Create a web app and note down the configuration

### 3. Web Application Setup

```bash
cd food
npm install

# Create environment file
cp .env.local.example .env.local

# Edit .env.local with your Firebase credentials
# Get values from Firebase Console → Project Settings
```

**Required Environment Variables:**
```env
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
VITE_FIREBASE_DATABASE_URL=https://your-project-default-rtdb.firebaseio.com
```

**Run Development Server:**
```bash
npm run dev
```

**Build for Production:**
```bash
npm run build
```

### 4. Flutter App Setup

```bash
cd flutter-app
flutter pub get
```

**Update Firebase Configuration:**
Edit `lib/main.dart` with your Firebase credentials (lines 16-23).

**Run on Device:**
```bash
# Check connected devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

## 🗄️ Database Structure

```
apartment-fv-default-rtdb/
├── menuMaster/              # All menu items (master list)
│   └── {itemId}/
│       ├── name
│       ├── price
│       ├── description
│       ├── meal (breakfast/lunch/snack/dinner)
│       └── imageUrl
│
├── activeMenu/              # Currently visible menu items
│   └── {itemId}/           # Same structure as menuMaster
│
├── orders/                  # Customer orders
│   └── {orderId}/
│       ├── name
│       ├── blockDoor
│       ├── mobile
│       ├── items/
│       ├── total
│       ├── status (pending/accepted/completed)
│       └── createdAt (server timestamp)
│
└── shopSchedule/            # Opening hours
    ├── openTime
    ├── closeTime
    ├── timezone
    └── isOpen
```

## 🔐 Security Rules

Deploy these rules to Firebase RTDB:

```json
{
  "rules": {
    "menuMaster": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "activeMenu": {
      ".read": true,
      ".write": "auth != null"
    },
    "orders": {
      ".read": "auth != null",
      ".write": true,
      "$orderId": {
        ".validate": "newData.hasChildren(['name', 'blockDoor', 'mobile', 'items', 'total'])"
      }
    },
    "shopSchedule": {
      ".read": true,
      ".write": "auth != null"
    }
  }
}
```

## 🌐 Deployment

### Web Application

**Recommended: Netlify**

1. Connect GitHub repository to Netlify
2. Set build command: `npm run build`
3. Set publish directory: `dist`
4. Add environment variables in Netlify dashboard

**Alternative: Vercel, Firebase Hosting**

### Flutter App

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Offline Functionality

Both web and mobile apps support offline operation:

- **Cached Data**: Previously loaded data is available offline
- **Queued Writes**: Changes are stored locally and synced when online
- **Visual Indicators**: Connection status banners and pending sync badges
- **Optimistic UI**: Changes appear immediately before server confirmation

## 🔑 Default Admin Login

Create an admin user in Firebase Authentication:

```
Email: admin@apartmentcafe.com
Password: [set in Firebase Console]
```

## 📚 Documentation

- [Web App Documentation](food/README.md)
- [Flutter App Setup](flutter-app/README.md)
- [Offline Implementation](flutter-app/OFFLINE_IMPLEMENTATION.md)
- [Project Summary](food/PROJECT_SUMMARY.md)
- [System Flows](food/SYSTEM_FLOWS.md)

## 🛠️ Tech Stack

**Web:**
- React 18
- Vite
- Firebase JS SDK
- Framer Motion
- React Router

**Mobile:**
- Flutter 3.x
- Firebase Flutter plugins
- Provider (state management)

## 📝 License

MIT

## 🤝 Contributing

See [CONTRIBUTING.md](food/CONTRIBUTING.md)

## 🐛 Known Issues

- Automatic menu deactivation at closing time requires client app to be running (no Cloud Functions in Spark plan)
- iOS background restrictions may affect offline sync timing

## 📧 Support

For issues and questions, please open a GitHub issue.

---

Built with ❤️ for apartment communities
