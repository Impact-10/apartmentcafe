# 🚀 Quick Start Guide - Apartment Café

Get your food ordering system up and running in 15 minutes!

## ⚡ Prerequisites Checklist

- [ ] Node.js 18+ installed (`node --version`)
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] Firebase account (free tier is sufficient)
- [ ] Git (optional)

## 📋 Step-by-Step Setup

### 1️⃣ Install Dependencies (2 minutes)

```bash
# Install frontend dependencies
npm install

# Install Cloud Functions dependencies
cd functions
npm install
cd ..
```

### 2️⃣ Create Firebase Project (3 minutes)

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add project"
3. Name it (e.g., "apartment-cafe")
4. Disable Google Analytics (optional)
5. Click "Create project"

### 3️⃣ Enable Firestore (1 minute)

1. In Firebase Console, click "Firestore Database"
2. Click "Create database"
3. Select "Production mode"
4. Choose a region (closest to your users)
5. Click "Enable"

### 4️⃣ Configure Your App (3 minutes)

1. In Firebase Console, go to Project Settings (gear icon)
2. Scroll to "Your apps" → Click web icon (</>)
3. Register app (name: "apartment-cafe-web")
4. Copy the config object

5. Create `.env` file in project root:
```bash
cp .env.example .env
```

6. Edit `.env` and paste your Firebase config:
```env
VITE_FIREBASE_API_KEY=AIza...
VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your-project-id
VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=123...
VITE_FIREBASE_APP_ID=1:123...
VITE_FUNCTIONS_BASE_URL=https://us-central1-your-project-id.cloudfunctions.net
VITE_ADMIN_SECRET=choose_a_secure_random_string_here
```

### 5️⃣ Deploy Firebase Services (5 minutes)

```bash
# Login to Firebase
firebase login

# Initialize Firebase (if not already done)
firebase init

# Select:
# - Firestore, Functions, Hosting
# - Use existing project
# - Accept default Firestore rules
# - JavaScript for Functions
# - Install dependencies: Yes
# - Public directory: dist
# - Single-page app: Yes

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Set admin secret for Cloud Functions
firebase functions:config:set admin.secret="your_secure_random_string"

# Deploy Cloud Functions
firebase deploy --only functions
```

**Important**: After deploying functions, copy the function URLs and update `.env`:
```env
VITE_FUNCTIONS_BASE_URL=https://us-central1-your-project-id.cloudfunctions.net
```

### 6️⃣ Add Sample Menu Data (1 minute)

**Option A: Manual (Firebase Console)**
1. Go to Firestore Database
2. Click "Start collection" → Name: `menu`
3. Add a document:
```json
{
  "name": "Masala Dosa",
  "price": 70,
  "meal": "breakfast",
  "enabled": true,
  "description": "Crispy dosa with potato filling",
  "imageUrl": ""
}
```

**Option B: Automated (Seed Script)**
```bash
cd scripts
npm install

# Download service account key from Firebase Console:
# Project Settings > Service Accounts > Generate New Private Key
# Save as: scripts/service-account-key.json

npm run seed
cd ..
```

### 7️⃣ Run Locally (30 seconds)

```bash
npm run dev
```

Visit:
- **Customer View**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin

## ✅ Testing Your Setup

### Test Customer Flow:
1. Open http://localhost:3000
2. You should see menu items (if enabled)
3. Add items to cart
4. Click "View Cart"
5. Click "Proceed to Checkout"
6. Fill in details and place order

### Test Admin Flow:
1. Open http://localhost:3000/admin
2. Click "Orders" tab → See the order you just placed
3. Click "Accept" → Status changes to "accepted"
4. Click "Complete" → Status changes to "completed"
5. Click "Menu" tab → Toggle items on/off

## 🌐 Deploy to Production

```bash
# Build and deploy everything
npm run build
firebase deploy

# Or use the deployment script
# Linux/Mac:
chmod +x deploy.sh
./deploy.sh

# Windows:
deploy.bat
```

Your app will be live at: `https://your-project-id.web.app`

## 🔧 Troubleshooting

### Issue: "Module not found" errors
**Solution**: Run `npm install` in both root and `functions/` directory

### Issue: Functions deployment fails
**Solution**: 
- Check Node.js version (should be 18+)
- Ensure Firebase billing is enabled (even for free tier Functions)
- Run `firebase login` again

### Issue: Menu items not showing
**Solution**:
- Check Firestore console → Is data there?
- Are items marked `enabled: true`?
- Check browser console for errors
- Verify `.env` file has correct Firebase config

### Issue: Orders not saving
**Solution**:
- Check Firestore rules are deployed: `firebase deploy --only firestore:rules`
- Check browser console for permission errors
- Verify Firebase config in `.env`

### Issue: Admin functions not working
**Solution**:
- Verify `VITE_ADMIN_SECRET` in `.env` matches Firebase config
- Check: `firebase functions:config:get`
- Ensure Functions are deployed: `firebase deploy --only functions`
- Check Functions logs: `firebase functions:log`

### Issue: CORS errors on admin actions
**Solution**: Functions automatically set CORS headers. If issues persist:
- Verify you're calling the correct Functions URL
- Check browser network tab for exact error
- Ensure Functions are deployed successfully

## 🎯 Next Steps

1. **Customize Menu**: Add real items with images
2. **Brand It**: Update colors in `src/styles.css` (CSS variables at top)
3. **Add Images**: Upload to Firebase Storage or use external URLs
4. **Test Mobile**: Open on your phone to test responsive design
5. **Share**: Send the URL to your apartment residents!

## 📱 Sharing with Residents

Once deployed, share:
- **Customer URL**: `https://your-project-id.web.app`
- **Instructions**: "Open link, browse menu, add to cart, checkout"
- **Payment**: "Cash on delivery - pay when you receive"

## 🔐 Admin Access

Keep the admin URL private:
- **Admin URL**: `https://your-project-id.web.app/admin`
- **Secret**: Only you have the `VITE_ADMIN_SECRET`
- **Security**: Never commit `.env` to version control

## 💡 Tips

- Update menu items daily by toggling `enabled` in admin panel
- Check orders regularly to accept and complete them
- Use Firebase Console for data backup and analytics
- Monitor Cloud Functions logs for errors

## 🎉 You're All Set!

Your modern food ordering system is ready. Happy cooking! 🍽️

---

Need help? Check the main [README.md](README.md) for detailed documentation.
