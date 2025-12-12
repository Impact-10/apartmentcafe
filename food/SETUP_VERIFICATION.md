# ✅ Setup Verification Checklist

Use this checklist to verify your Apartment Café installation is complete and working correctly.

## 📦 File Structure Verification

Run this command to verify all files are present:

```bash
# Windows (PowerShell)
Get-ChildItem -Recurse -File | Measure-Object | Select-Object Count

# Linux/Mac
find . -type f | wc -l
```

Expected: ~35-40 files

### Core Files Checklist

- [ ] `package.json` - Frontend dependencies
- [ ] `vite.config.js` - Vite configuration
- [ ] `index.html` - HTML entry
- [ ] `.env.example` - Environment template
- [ ] `.gitignore` - Git ignore rules

### Source Files

- [ ] `src/main.jsx` - React entry point
- [ ] `src/App.jsx` - Main app component
- [ ] `src/styles.css` - Main stylesheet
- [ ] `src/lib/firebase.js` - Firebase init
- [ ] `src/lib/api.js` - API wrapper

### Components (9 files)

- [ ] `src/components/Header.jsx`
- [ ] `src/components/Footer.jsx`
- [ ] `src/components/ScrollStackWrapper.jsx`
- [ ] `src/components/MenuSection.jsx`
- [ ] `src/components/ItemCard.jsx`
- [ ] `src/components/CartFloating.jsx`
- [ ] `src/components/CartModal.jsx`
- [ ] `src/components/CheckoutModal.jsx`
- [ ] `src/components/AdminPanel.jsx`

### Hooks (3 files)

- [ ] `src/hooks/useMenu.js`
- [ ] `src/hooks/useCart.js`
- [ ] `src/hooks/useOrders.js`

### Firebase Files

- [ ] `firebase.json` - Firebase config
- [ ] `firestore.rules` - Security rules
- [ ] `firestore.indexes.json` - Indexes
- [ ] `functions/index.js` - Cloud Functions
- [ ] `functions/package.json` - Functions deps

### Documentation

- [ ] `README.md` - Main documentation
- [ ] `QUICKSTART.md` - Quick setup guide
- [ ] `PROJECT_SUMMARY.md` - Project overview
- [ ] `scripts/README.md` - Scripts docs

### Scripts & Tools

- [ ] `deploy.sh` - Unix deployment script
- [ ] `deploy.bat` - Windows deployment script
- [ ] `scripts/seed-data.js` - Database seeding
- [ ] `scripts/package.json` - Script dependencies

## 🔧 Configuration Verification

### 1. Environment Variables

```bash
# Check .env file exists
test -f .env && echo "✅ .env exists" || echo "❌ .env missing - copy from .env.example"
```

Required variables in `.env`:
- [ ] `VITE_FIREBASE_API_KEY`
- [ ] `VITE_FIREBASE_AUTH_DOMAIN`
- [ ] `VITE_FIREBASE_PROJECT_ID`
- [ ] `VITE_FIREBASE_STORAGE_BUCKET`
- [ ] `VITE_FIREBASE_MESSAGING_SENDER_ID`
- [ ] `VITE_FIREBASE_APP_ID`
- [ ] `VITE_FUNCTIONS_BASE_URL`
- [ ] `VITE_ADMIN_SECRET`

### 2. Dependencies Installed

```bash
# Check node_modules exists
test -d node_modules && echo "✅ Frontend deps installed" || echo "❌ Run: npm install"

# Check functions dependencies
test -d functions/node_modules && echo "✅ Functions deps installed" || echo "❌ Run: cd functions && npm install"
```

### 3. Firebase CLI

```bash
# Check Firebase CLI is installed
firebase --version && echo "✅ Firebase CLI installed" || echo "❌ Run: npm i -g firebase-tools"

# Check logged in
firebase projects:list && echo "✅ Logged into Firebase" || echo "❌ Run: firebase login"
```

## 🔥 Firebase Project Verification

### Firestore Database

```bash
# Check if Firestore is enabled
firebase firestore:get /menu --limit 1
```

Expected: Either data or "collection not found" (both OK)
Error "Firestore not enabled": Enable in Firebase Console

### Cloud Functions

```bash
# List deployed functions
firebase functions:list
```

Expected functions:
- [ ] `toggleMenu`
- [ ] `updateOrderStatus`
- [ ] `webhookNotify`

### Hosting

```bash
# Check hosting status
firebase hosting:channel:list
```

## 🧪 Runtime Verification

### 1. Development Server

```bash
npm run dev
```

Expected output:
```
VITE v5.x.x  ready in xxx ms

➜  Local:   http://localhost:3000/
➜  Network: use --host to expose
```

- [ ] Server starts without errors
- [ ] Opens browser automatically
- [ ] No console errors

### 2. Test Homepage

Open http://localhost:3000

Expected:
- [ ] Header shows "Apartment Café"
- [ ] No JavaScript errors in console
- [ ] If no menu items: Shows "No menu items available"
- [ ] If menu items exist: Displays meal sections

### 3. Test Cart Functionality

1. Add menu item to cart
2. Check floating cart button appears
3. Click cart button
4. Cart modal opens with items

- [ ] Add to cart works
- [ ] Cart count updates
- [ ] Cart modal displays correctly
- [ ] Quantity controls work
- [ ] Remove button works

### 4. Test Checkout

1. Click "Proceed to Checkout"
2. Fill in form
3. Click "Place Order"

Expected:
- [ ] Form validation works
- [ ] Success message appears
- [ ] Order appears in Firestore

Verify in Firebase Console:
```
Firestore → orders → [new document with pending status]
```

### 5. Test Admin Panel

Open http://localhost:3000/admin

Expected:
- [ ] Admin panel loads
- [ ] "Orders" tab shows orders
- [ ] "Menu" tab shows all menu items
- [ ] Real-time updates work

Test admin actions:
- [ ] Toggle menu item (enabled ↔ disabled)
- [ ] Accept pending order
- [ ] Complete accepted order

## 🔐 Security Verification

### Firestore Rules Test

Try these operations (should fail):

```javascript
// In browser console on customer page
const { db } = await import('./src/lib/firebase.js');
const { setDoc, doc } = await import('firebase/firestore');

// This should FAIL (client cannot write to menu)
await setDoc(doc(db, 'menu', 'test'), { name: 'Test' });
// Expected: "Missing or insufficient permissions"

// This should FAIL (client cannot update orders)
await setDoc(doc(db, 'orders', 'order123'), { status: 'accepted' });
// Expected: "Missing or insufficient permissions"
```

- [ ] Client cannot write to menu
- [ ] Client cannot update orders

### Cloud Functions Auth Test

Try calling function without secret:

```bash
curl -X POST https://your-functions-url/toggleMenu \
  -H "Content-Type: application/json" \
  -d '{"itemId": "test", "enabled": true}'
```

Expected: `401 Unauthorized`

- [ ] Functions reject requests without secret

## 📱 Mobile Responsiveness Test

Test on mobile device or use browser dev tools (F12 → Device toolbar):

- [ ] Header displays correctly
- [ ] Menu items stack vertically
- [ ] Cart button visible and clickable
- [ ] Modals are full-screen friendly
- [ ] Forms are usable
- [ ] Admin panel is functional

## ⚡ Performance Verification

### Build Test

```bash
npm run build
```

Expected:
- [ ] Build completes without errors
- [ ] `dist/` folder created
- [ ] No warnings about bundle size

### Lighthouse Test (Optional)

1. Build and serve: `npm run build && npm run preview`
2. Open Chrome DevTools → Lighthouse
3. Run audit

Target scores:
- Performance: 80+
- Accessibility: 90+
- Best Practices: 90+
- SEO: 80+

## 🚀 Deployment Verification

### Pre-deployment Check

- [ ] `.env` file is NOT committed
- [ ] All sensitive keys are in environment variables
- [ ] Build works: `npm run build`
- [ ] Firebase project selected: `firebase use`

### Deploy to Firebase

```bash
firebase deploy
```

Expected output:
```
✔  Deploy complete!

Hosting URL: https://your-project.web.app
```

### Post-deployment Test

Visit your production URL and test:
- [ ] Homepage loads
- [ ] Menu displays
- [ ] Cart works
- [ ] Orders can be placed
- [ ] Admin panel works
- [ ] HTTPS is enabled
- [ ] Custom domain (if configured)

## 📊 Monitoring Setup

### Firebase Console Checks

1. **Firestore Usage**
   - Console → Firestore → Usage tab
   - [ ] Monitor daily reads/writes

2. **Functions Logs**
   - Console → Functions → Logs
   - [ ] Check for errors
   - [ ] Monitor execution times

3. **Hosting Traffic**
   - Console → Hosting → Usage
   - [ ] Track bandwidth
   - [ ] Check for errors

## ✅ Final Checklist

Before going live:

- [ ] All tests passed
- [ ] Documentation reviewed
- [ ] Admin secret is secure (not in code)
- [ ] Firebase billing alert set up
- [ ] Backup strategy in place
- [ ] Monitoring enabled
- [ ] Support contact set up
- [ ] Residents informed about the new system

## 🎉 Success Criteria

Your setup is complete and verified if:

1. ✅ Homepage loads without errors
2. ✅ Menu items display in real-time
3. ✅ Cart and checkout work end-to-end
4. ✅ Orders save to Firestore
5. ✅ Admin can manage menu and orders
6. ✅ Security rules prevent unauthorized access
7. ✅ Mobile responsive design works
8. ✅ Deployed and accessible online

## 🆘 Troubleshooting Failed Checks

### Build Fails
```bash
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Functions Not Working
```bash
cd functions
rm -rf node_modules package-lock.json
npm install
cd ..
firebase deploy --only functions
```

### Firestore Permission Errors
```bash
firebase deploy --only firestore:rules
```

### Environment Variables Not Loading
- Restart dev server after changing `.env`
- Ensure variables start with `VITE_`
- Check for typos in variable names

## 📞 Need Help?

- Check [README.md](README.md) for detailed docs
- Review [QUICKSTART.md](QUICKSTART.md) for setup steps
- Check Firebase Console logs
- Review browser console for errors
- Check `firebase functions:log` for backend errors

---

**All checks passed?** 🎉 You're ready to go live!
