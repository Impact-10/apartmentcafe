# Apartment Café - Flutter App

A production-ready Flutter app (Android + iOS) for managing restaurant orders using Firebase Realtime Database.

## Features

### Admin Panel
- **Master Menu Management**: Create, edit, delete menu items
- **Section-based Publishing**: Toggle items on/off by meal section (Breakfast, Lunch, Snack, Dinner), then publish active menu in one tap
- **Shop Schedule**: Set open/close times, activate/deactivate shop, auto-clear menu at close time (client-driven)
- **Order Management**: View pending orders in real-time, accept orders, view order history

### Customer App
- **Real-time Menu**: See live menu updates as admin publishes changes
- **Business Hours Check**: Menu only visible during shop hours
- **Shopping Cart**: Add items, adjust quantities, remove items
- **Order Placement**: Checkout with name, block/flat, mobile number
- **Order Confirmation**: Get order ID and status

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (stable version)
- Firebase project (`apartment-fv`) with RTDB and Auth configured
- Admin email/password for Firebase Auth

### 2. Clone and Install

```bash
cd flutter-app
flutter pub get
```

### 3. Firebase Configuration

All Firebase config is hardcoded in `lib/main.dart`. Values are:
- **Database URL**: `https://apartment-fv-default-rtdb.firebaseio.com`
- **Project ID**: `apartment-fv`

No additional setup needed; app connects automatically.

### 4. Create Admin User

In Firebase Console:
1. Go to **Authentication**
2. Click **Add User**
3. Enter email and password
4. Copy the **UID** of the created admin
5. Update `database.rules.json`: Replace `gyiR11vZLnZO3ccMF9UphetxhrA2` with the admin UID

### 5. Deploy RTDB Rules

```bash
firebase deploy --only database
```

This deploys security rules that protect admin-only writes.

### 6. Seed Master Menu (Optional)

In Firebase Console → RTDB:
1. Create a `/menuMaster` node
2. Import sample data from `../food/seed-menu.json` (or create manually)

Each menu item needs:
```json
{
  "name": "Item Name",
  "price": 100,
  "meal": "breakfast|lunch|snack|dinner",
  "enabled": true,
  "imageUrl": "",
  "description": "Item description"
}
```

### 7. Run the App

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run -d <ios-device>
```

Or use VS Code/Android Studio to run the app.

## Project Structure

```
lib/
├── main.dart                 # App entry, auth gate, role selection
├── firebase_options.dart     # Firebase config
├── models/
│   ├── menu_item.dart       # MenuItem model
│   ├── order.dart           # Order & CartItem models
│   └── schedule.dart        # ShopSchedule model
├── services/
│   ├── firebase_service.dart  # RTDB read/write helpers
│   └── schedule_service.dart  # Business hours logic
├── providers/
│   ├── cart_provider.dart     # Cart state (Provider)
│   └── admin_menu_provider.dart  # Admin menu state
├── screens/
│   ├── admin/
│   │   ├── admin_login.dart       # Email/password login
│   │   ├── admin_dashboard.dart   # Main admin UI (3-tab layout)
│   │   ├── master_item_editor.dart # CRUD for menu items
│   │   ├── section_editor.dart     # Toggle & publish by section
│   │   ├── schedule_editor.dart    # Set hours & activate/deactivate
│   │   └── admin_orders.dart       # Pending & history tabs
│   └── customer/
│       ├── home.dart      # Menu display with section tabs
│       ├── cart.dart      # Cart UI
│       └── checkout.dart  # Order form & placement
└── widgets/
    └── (reusable components)
```

## Data Model (RTDB)

### `/menuMaster/{itemId}`
Master catalogue (admin creates/edits):
```json
{
  "name": "String",
  "price": "Int",
  "meal": "breakfast|lunch|snack|dinner",
  "enabled": "Boolean",
  "imageUrl": "String",
  "description": "String"
}
```

### `/activeMenu/{itemId}`
Daily active menu (admin publishes as full replace):
```json
{
  "name": "String",
  "price": "Int",
  "meal": "breakfast|lunch|snack|dinner",
  "enabled": true,
  "imageUrl": "String",
  "description": "String"
}
```

### `/shopSchedule`
Shop timing (singleton):
```json
{
  "openTime": "07:00",
  "closeTime": "21:00",
  "timezone": "Asia/Kolkata",
  "isOpen": true,
  "updatedAt": 1702345678000
}
```

### `/orders/{pushId}`
Customer orders:
```json
{
  "name": "Customer Name",
  "blockDoor": "A-501",
  "mobile": "9876543210",
  "items": {
    "m1": { "id": "m1", "name": "Poori", "qty": 2, "price": 45 },
    "m3": { "id": "m3", "name": "Masala Dosa", "qty": 1, "price": 70 }
  },
  "total": 160,
  "status": "pending|accepted|completed",
  "createdAt": 1702345678000
}
```

## Admin Workflow

1. **Add/Edit Items** (Master Menu):
   - Tap 3-dot menu → "Manage Master Menu"
   - Add name, meal type, price, description
   - Items saved to `/menuMaster`

2. **Publish Daily Menu** (Section Editor tab):
   - Select meal section (Breakfast, Lunch, Snack, Dinner)
   - Toggle items ON/OFF with checkboxes
   - Tap **Publish** → Confirmation dialog
   - Only enabled items are written to `/activeMenu` (full replace)

3. **Set & Activate Schedule** (Schedule Editor tab):
   - Set opening time (e.g., 07:00)
   - Set closing time (e.g., 21:00)
   - Tap **Activate Now**
   - Updates `/shopSchedule.isOpen = true` and publishes current menu

4. **Deactivate Shop**:
   - Tap **Deactivate Now** button
   - Sets `isOpen = false` and clears `/activeMenu`
   - **Auto-deactivate**: If admin app is running, it will auto-deactivate at close time (client-driven)

5. **Manage Orders** (Orders tab):
   - **Pending**: Shows pending orders; tap **Accept** to mark as `accepted`
   - **History**: Shows completed & accepted orders; tap to mark completed

## Customer Workflow

1. **Browse Menu** (Home screen):
   - App checks `/shopSchedule.isOpen`
   - If closed, shows "Closed — Opens at HH:mm"
   - If open & within hours, displays `/activeMenu` grouped by meal

2. **Shop & Checkout**:
   - Tap **Add** to add items to cart
   - Tap cart icon → Review items
   - Tap **Proceed to Checkout**
   - Enter name, block/flat, mobile (10 digits)
   - Tap **Place Order**
   - Get order ID confirmation

3. **Real-time Updates**:
   - Menu updates immediately when admin publishes
   - Shop closure shows live update

## Important Notes

### Publishing Menu
- Pressing **Publish** in Section Editor writes `/activeMenu` as a **full replace** (using `set()`)
- This prevents duplicate items and ensures clean state
- Previous active menu is completely overwritten

### Auto-Deactivate
- **Client-driven approach**: Admin device checks every minute if current time > close time
- If yes, app clears `/activeMenu` automatically
- **Limitation**: Only works if admin app is running (foreground or background)
- **Future enhancement**: Deploy Cloud Functions to auto-clear at server time (requires Blaze plan)

### Security
- RTDB rules protect `/menuMaster`, `/activeMenu`, `/shopSchedule` writes (admin UID only)
- `/orders` can be created by anyone (customers), but only admin can update status
- Customers do NOT require Firebase Auth to place orders

### Offline Usage
- App uses Firebase SDK which handles offline queuing
- Orders placed offline will sync when connection restored
- Menu reads are from cache if offline

## Troubleshooting

### App Shows "Shop is Closed" But Should Be Open
- Check `/shopSchedule.isOpen` in Firebase Console
- Verify current device time is within `openTime` and `closeTime`
- Time comparison is HH:mm format (24-hour)

### Menu Not Updating in Real-time
- Ensure `/activeMenu` data exists in RTDB
- Check RTDB rules allow `.read` access
- Force app refresh (hot reload)

### Admin Login Fails
- Verify admin email/password are correct
- Check admin user exists in Firebase Auth
- Ensure admin UID in rules matches created user's UID

### Orders Not Appearing
- Confirm `/orders` node exists in RTDB
- Check RTDB rules allow `.write` for new orders
- Verify order data is valid (all required fields)

## Testing Checklist

- [ ] Admin logs in with email/password
- [ ] Admin can add item to master menu
- [ ] Admin can toggle item enabled in Section Editor
- [ ] Admin taps Publish → menu is written to `/activeMenu` (verify in console)
- [ ] Customer app loads menu from `/activeMenu` in real-time
- [ ] Admin sets schedule (e.g., 08:00 - 20:00) and Activate
- [ ] Customer sees menu only if current time is 08:00 - 20:00
- [ ] Outside hours, customer sees "Closed — Opens at 08:00"
- [ ] Customer adds items, adjusts cart, proceeds to checkout
- [ ] Customer enters name, block, mobile → places order
- [ ] Order appears under `/orders` with status `pending`
- [ ] Admin sees pending order in Orders tab
- [ ] Admin taps Accept → order status changes to `accepted`
- [ ] Admin taps Deactivate Now → `/activeMenu` clears, customer sees "Closed"
- [ ] Multiple items in cart calculate correct total

## Security Considerations

1. **Admin UID Protection**: The admin UID (`gyiR11vZLnZO3ccMF9UphetxhrA2`) in rules must be kept secret
2. **Firebase Rules Audit**: Regularly review RTDB rules to ensure only admin UID can write sensitive nodes
3. **Customer Privacy**: Mobile numbers and names are visible to admin; consider encryption if needed
4. **Firebase Credentials**: Config values in app are public (standard for web apps), but not a security risk

## Future Enhancements

- [ ] Image upload for menu items (Firebase Storage)
- [ ] Order status notifications for customers
- [ ] Multiple admin support (multi-UID in rules)
- [ ] Cloud Functions for server-side auto-deactivate (requires Blaze plan)
- [ ] Analytics dashboard
- [ ] Push notifications for order updates
- [ ] Payment gateway integration

## License

MIT

---

**Questions?** Check Firebase docs or review code comments for implementation details.
