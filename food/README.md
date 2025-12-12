# Apartment Café (RTDB + Auth, No Billing)

Spark-plan friendly apartment-only food ordering MVP using React + Firebase Realtime Database and a single admin login. No Firestore. No Cloud Functions. No Blaze. Hosting optional.

## What’s included
- RTDB data model: `/menu` (public read, admin-only writes) and `/orders` (public create, admin-only update/delete)
- Admin auth: single email/password account (Firebase Auth)
- Resident UI: browse 4 sections (Breakfast, Lunch, Evening Snack, Dinner), cart + checkout (name, block/flat, mobile), place order to RTDB
- Admin UI: sign in, see pending orders, one-tap Accept → `status: completed`, toggle menu `enabled`
- Animations/UI: Framer Motion + ScrollStack-style layout, floating cart

## Environment (.env.local)
Create `.env.local` from `.env.local.example`:
```
VITE_FIREBASE_API_KEY=AIzaSyCVGJkGudLVlzJHRE4JACqEcE--Qxonpe8
VITE_FIREBASE_AUTH_DOMAIN=apartment-fv.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=apartment-fv
VITE_FIREBASE_STORAGE_BUCKET=apartment-fv.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=176790456882
VITE_FIREBASE_APP_ID=1:176790456882:web:531dec259ece9244e1ca2b
VITE_FIREBASE_MEASUREMENT_ID=G-MTDBNYKWGP
VITE_FIREBASE_DATABASE_URL=https://apartment-fv.firebaseio.com
```

## Firebase setup (no billing)
1) Init (CLI) — Hosting only
```
firebase init
# Select ONLY: Hosting (optional if you deploy frontend)
# public: dist
# single-page app: yes
# GitHub deploys: no
# Do NOT select Firestore, Functions, or anything that enables Cloud Build/Artifact Registry.
```

2) Create RTDB (console)
- Console → Realtime Database → Create Database → region of choice → **locked mode**.
- Do NOT enable Firestore or Functions.

3) Create admin user
- Console → Authentication → Add user (email/password) → copy UID.
- For this project, admin UID is already set to `gyiR11vZLnZO3ccMF9UphetxhrA2` in rules.

4) RTDB rules
File: `database.rules.json`
```
{
  "rules": {
    "menu": {
      ".read": true,
      ".write": "auth != null && auth.uid === 'gyiR11vZLnZO3ccMF9UphetxhrA2'"
    },
    "orders": {
      ".read": true,
      ".write": "(!data.exists() && newData.exists()) || (auth != null && auth.uid === 'gyiR11vZLnZO3ccMF9UphetxhrA2')"
    }
  }
}
```
Deploy rules:
```
firebase deploy --only database
```

5) Hosting deploy (optional)
```
npm run build
firebase deploy --only hosting
```
`firebase.json` contains only Hosting + RTDB rules; no functions, no firestore.

## Seed menu
- Console → RTDB → Data tab → import `seed-menu.json` into `/menu`.
- Item shape under `/menu/{id}`:
```
{
  "name": "Masala dosa",
  "price": 70,
  "meal": "breakfast",
  "enabled": true,
  "imageUrl": "",
  "description": ""
}
```

## Run locally
```
npm install
npm run dev
```
- Resident UI at `/` streams menu (enabled) and writes orders to `/orders`.
- Admin UI at `/admin` → sign in with the email/password you created.

## Data layer (RTDB)
- `src/lib/firebase.js` → `getAuth`, `getDatabase`, exports `auth`, `db`, `serverTimestamp`
- `src/hooks/useMenuRTDB.js` → realtime menu (enabled + full list)
- `src/lib/ordersRTDB.js` → `placeOrder`, `adminAccept`, `listenOrdersPending`, `listenOrdersHistory`

## UI flow
- Customer checkout: [CheckoutModal](src/components/CheckoutModal.jsx) → `placeOrder` writes push entry in `/orders` with `status: pending`
- Admin: [AdminLogin](src/components/AdminLogin.jsx) (Auth) → [AdminOrders](src/components/AdminOrders.jsx) streams pending/history; Accept sets `status: completed`; menu toggles write to `/menu/{id}/enabled`

## Billing safety checklist
- No Cloud Functions folder or config
- No Firestore files or imports
- `firebase.json` only Hosting + RTDB rules
- If CLI prompts for Cloud Build/Artifact Registry, cancel and re-run selecting only Hosting

## Testing
1. Resident places order → `/orders` shows new child with `status: pending`.
2. Admin signs in at `/admin` → sees pending order.
3. Admin taps Accept → order `status` becomes `completed` in RTDB.
4. Admin toggles a menu item → resident UI updates live.
