# Apartment Café - Testing Checklist

Use this checklist to validate the Flutter app before deployment.

## Pre-Launch Setup

- [ ] Firebase project created (`apartment-fv`)
- [ ] RTDB created in locked mode
- [ ] Firebase Auth enabled
- [ ] Admin user created (email/password)
- [ ] Admin UID copied and updated in `database.rules.json`
- [ ] RTDB rules deployed: `firebase deploy --only database`
- [ ] Menu master data seeded (at least 5 items across 4 meals)
- [ ] Shop schedule initialized (optional; can be set from app)

## Admin Flow

### Login
- [ ] App shows role selection screen on first launch
- [ ] Tap "Admin Login"
- [ ] Enter correct email → succeeds, goes to Admin Dashboard
- [ ] Try wrong password → shows error message
- [ ] Log out via 3-dot menu → back to role selection

### Master Menu Management
- [ ] Tap 3-dot menu → "Manage Master Menu"
- [ ] Tap **+** button → Add Item dialog opens
- [ ] Fill in name, meal type, price, description, image URL
- [ ] Tap Save → item appears in list
- [ ] Tap item → Edit dialog opens with pre-filled values
- [ ] Edit price → Tap Save → item updates in list
- [ ] Delete item → Confirm dialog → item removed from list
- [ ] Menu items written to `/menuMaster` in RTDB (verify in console)

### Section Editor (Publish Menu)
- [ ] Go to Menu tab (first tab in Admin Dashboard)
- [ ] Section tabs show: BREAKFAST, LUNCH, SNACK, DINNER
- [ ] Tap each tab → shows only items for that meal
- [ ] Items have checkboxes and descriptions visible
- [ ] Tap checkbox → toggles item selection
- [ ] Select 3-4 items from Breakfast, 3-4 from Lunch, etc.
- [ ] Tap **Publish** → Confirmation dialog appears
- [ ] Read confirmation: "This will replace the current Active Menu"
- [ ] Tap Publish in dialog → loading indicator, then success message
- [ ] Verify `/activeMenu` in Firebase console contains only selected items
- [ ] **KEY VALIDATION**: `/activeMenu` must be a full replace (no duplicates, no stale data)

### Schedule Editor (Hours & Activation)
- [ ] Go to Schedule tab (second tab in Admin Dashboard)
- [ ] Card shows current status: OPEN or CLOSED
- [ ] Tap clock icon next to "Opening Time" → time picker opens
- [ ] Select 08:00 → text field updates to "08:00"
- [ ] Tap clock icon next to "Closing Time" → time picker opens
- [ ] Select 20:00 → text field updates to "20:00"
- [ ] Timezone field pre-filled with "Asia/Kolkata"
- [ ] Tap **Activate Now** → loading indicator
- [ ] `/shopSchedule` updates with openTime, closeTime, isOpen:true
- [ ] Status card updates to show "OPEN"
- [ ] Tap **Deactivate Now** → confirmation dialog
- [ ] Confirm → loading → `/shopSchedule.isOpen` becomes false
- [ ] Status card updates to show "CLOSED"
- [ ] `/activeMenu` is cleared (empty object {} in RTDB)

### Order Management
- [ ] Go to Orders tab (third tab in Admin Dashboard)
- [ ] Two tabs: Pending, History
- [ ] **Pending tab**:
  - [ ] Shows all orders with status='pending'
  - [ ] Displays: name, block, mobile, items list, total, status badge
  - [ ] Tap **Accept** button → status changes to 'accepted'
  - [ ] Accepted order moves to History tab
- [ ] **History tab**:
  - [ ] Shows all non-pending orders (accepted, completed)
  - [ ] Orders sorted by date (newest first)
  - [ ] Tap order with status='accepted' → status changes to 'completed'

## Customer Flow

### Home Screen (Menu Browsing)
- [ ] Start as "Customer" from role selection
- [ ] Home screen loads with section tabs: BREAKFAST, LUNCH, SNACK, DINNER
- [ ] **If shop is CLOSED** (isOpen:false):
  - [ ] Display: "Shop is Closed — Opens at HH:mm"
  - [ ] NO menu items visible
- [ ] **If shop is OPEN** (isOpen:true):
  - [ ] Display active menu from `/activeMenu`
  - [ ] Items grouped by meal section
  - [ ] Each item shows: name, description, price, **Add** button
  - [ ] Tap section tab → menu switches to that meal's items
  - [ ] Cart counter at top-right shows "0 items"
  - [ ] **FAB (Floating Action Button) is hidden** when cart is empty

### Shopping & Cart
- [ ] Tap **Add** on a menu item → "Item Name added to cart" snackbar
- [ ] Cart counter updates to "1 items"
- [ ] FAB appears: "Cart (1)"
- [ ] Add another item → counter "2 items"
- [ ] Add same item again → counter "3 items" (not duplicate line in cart)
- [ ] Tap FAB → Cart screen opens
- [ ] Cart shows all items with quantities
- [ ] Each item has: name, price×qty, **-** and **+** buttons, **X** (remove) button
- [ ] Tap **+** → quantity increases, total updates
- [ ] Tap **-** → quantity decreases
- [ ] Tap **-** when qty=1 → item removed from cart
- [ ] Tap **X** → item removed
- [ ] Card at bottom shows: **Total: ₹XYZ**
- [ ] Tap **Proceed to Checkout** → Checkout screen opens

### Checkout & Order Placement
- [ ] Checkout form shows 3 fields: Name, Block/Flat, Mobile
- [ ] All fields empty initially
- [ ] Leave fields blank → tap **Place Order** → error "All fields required"
- [ ] Enter name "John", block "A-501", mobile "9876543210" (valid 10 digits)
- [ ] Order Summary card shows: item names, quantities, prices, total
- [ ] Tap **Place Order** → loading indicator
- [ ] Order placed successfully → Success dialog:
  - [ ] Title: "Order Placed!"
  - [ ] Shows Order ID (Firebase push key)
  - [ ] Shows Status: "Pending"
  - [ ] Tap **Back to Menu** → returns to Menu screen, cart cleared
- [ ] Verify `/orders` in Firebase console:
  - [ ] New order entry created
  - [ ] Contains: name, blockDoor, mobile, items object, total, status:pending, createdAt
  - [ ] **NO duplicates** if placed multiple times

### Real-time Updates
- [ ] **Menu Update**: While customer app is viewing menu:
  - [ ] Admin publishes new items to `/activeMenu`
  - [ ] Customer menu refreshes automatically without app restart
  - [ ] New items appear in section
  - [ ] Removed items disappear
- [ ] **Shop Close**: While customer app is open:
  - [ ] Admin taps Deactivate
  - [ ] Customer app shows "Shop is Closed" message
  - [ ] Menu items disappear
  - [ ] No need to restart app

### Edge Cases
- [ ] Mobile field rejects non-numeric input
- [ ] Mobile field limits to 10 digits max
- [ ] Mobile "9876543210" (valid) → succeeds
- [ ] Mobile "987654321" (9 digits) → error "must be 10 digits"
- [ ] Empty cart → FAB hidden, can't access checkout
- [ ] Order placed with 1 item → succeeds, `/orders` has 1 item in items object
- [ ] Order placed with 5 items → succeeds, `/orders` has all 5 items
- [ ] Total calculation: qty × price for each item, sum all → matches displayed total

## Data Consistency (RTDB Verification)

Using Firebase Console RTDB viewer:

- [ ] **After Admin Adds Item**:
  - [ ] `/menuMaster/{newId}` contains item data
  - [ ] Format: { name, price, meal, enabled, imageUrl, description }

- [ ] **After Admin Publishes Menu**:
  - [ ] `/activeMenu` completely replaced (old items gone)
  - [ ] `/activeMenu` contains ONLY selected items
  - [ ] No duplicate keys
  - [ ] Every item has enabled:true

- [ ] **After Admin Activates Schedule**:
  - [ ] `/shopSchedule` exists
  - [ ] Contains: openTime, closeTime, timezone, isOpen:true, updatedAt (timestamp)

- [ ] **After Admin Deactivates**:
  - [ ] `/shopSchedule.isOpen` = false
  - [ ] `/activeMenu` is empty object {} (or cleared)

- [ ] **After Customer Places Order**:
  - [ ] `/orders/{pushId}` created
  - [ ] Contains: name, blockDoor, mobile, items:{m1:{...}, m3:{...},...}, total, status:pending, createdAt

## Performance & UI

- [ ] Menu loads in < 2 seconds
- [ ] Cart calculations instant (no lag when adding/removing items)
- [ ] Order submission takes 1-3 seconds
- [ ] Admin screens responsive (no ANR / frozen UI)
- [ ] Landscape orientation works (if tested)
- [ ] Text is readable (no overflow)
- [ ] Images (if added) display correctly

## Network & Offline

- [ ] Order placed on WiFi → succeeds immediately
- [ ] Order placed on slow connection → shows loading, succeeds
- [ ] App started offline → displays "loading" or graceful error
- [ ] Connection restored → real-time listeners reconnect, data updates

## Final Acceptance

- [ ] All admin tests passed
- [ ] All customer tests passed
- [ ] All data consistency checks passed
- [ ] No crashes or errors in Logcat/Console
- [ ] RTDB rules verified (admin UID is correct)
- [ ] No hardcoded secrets in app code (config is OK, auth secrets not in repo)
- [ ] README updated with instructions
- [ ] Testing checklist completed and signed off

---

**Tested By**: ___________________  
**Date**: ___________________  
**Notes**: _________________________________________________
