# Deployment Guide - V1 MVP

## Prerequisites
- Firebase project configured
- GitHub repository connected to Vercel
- Firebase CLI installed (`npm install -g firebase-tools`)
- Git repository initialized

## Deployment Steps

### Step 1: Verify Changes Locally
```bash
cd d:\work\FoodV\food
npm run dev
```
- Test order placement flow
- Test OrderTracker component
- Test admin dashboard with 3 sections

### Step 2: Deploy Database Rules
```bash
# Login to Firebase (if not already)
firebase login

# Deploy rules only
firebase deploy --only database
```

Expected output:
```
✔ Deploy complete!

Resources:
  - https://console.firebase.google.com/project/YOUR_PROJECT/database
```

### Step 3: Commit and Push
```bash
# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "feat: Implement V1 MVP order tracking and lifecycle

- Add session-based OrderTracker component
- Implement 3-state order lifecycle (pending → accepted → delivered)
- Add automatic order archival to ordersHistory
- Update admin dashboard with 3-section UI
- Update RTDB security rules for ordersHistory
- Remove unused Squares component files
- Update status badge styles"

# Push to GitHub (triggers Vercel auto-deploy)
git push origin main
```

### Step 4: Verify Vercel Deployment
1. Visit [Vercel Dashboard](https://vercel.com/dashboard)
2. Check deployment status
3. Wait for "Ready" status (~2-3 minutes)
4. Visit [apartmentcafe.vercel.app](https://apartmentcafe.vercel.app)

### Step 5: Test Production
1. **Customer flow**:
   - Place test order
   - Verify localStorage has `lastOrderId`
   - Verify OrderTracker appears
   
2. **Admin flow**:
   - Login at `/admin`
   - Accept pending order
   - Mark accepted order as delivered
   - Wait 3 seconds - verify disappears
   
3. **Firebase Console**:
   - Check `/orders` path (should be empty after archival)
   - Check `/ordersHistory/{today's date}` (should have archived order)

## Rollback Plan

If issues occur:

### Quick Rollback (Code)
```bash
# Revert to previous commit
git revert HEAD
git push origin main
```

### Rollback Database Rules
```bash
# Edit database.rules.json to previous version
git checkout HEAD~1 database.rules.json
firebase deploy --only database
git checkout database.rules.json
```

## Monitoring

### Check Logs
- **Vercel**: [Deployment logs](https://vercel.com/dashboard)
- **Firebase**: [Console → Database → Usage](https://console.firebase.google.com)
- **Browser**: Open DevTools → Console

### Common Issues

**OrderTracker not appearing**:
- Check localStorage for `lastOrderId` key
- Verify order exists in `/orders/{orderId}`
- Check browser console for Firebase errors

**Admin sections empty**:
- Verify Firebase authentication
- Check RTDB rules deployed correctly
- Verify orders have `status` field

**Orders not archiving**:
- Check browser console for errors
- Verify `/ordersHistory` path in RTDB rules
- Check admin has write permissions

## Post-Deployment Checklist

- [ ] Website loads at apartmentcafe.vercel.app
- [ ] No console errors on homepage
- [ ] Customer can place order successfully
- [ ] OrderTracker appears after checkout
- [ ] Admin can see pending orders
- [ ] Admin can accept orders (moves to Accepted section)
- [ ] Admin can mark delivered (moves to Delivered section)
- [ ] Orders archive after 3 seconds
- [ ] `/ordersHistory/{date}` populated in Firebase
- [ ] Status badge colors display correctly
- [ ] Mobile responsive (test on phone)

## Firebase Spark Plan Monitoring

Check these metrics weekly:
- **Realtime Database**: [Firebase Console → Usage](https://console.firebase.google.com)
- **Simultaneous connections**: Should stay < 100
- **GB downloaded**: Should stay < 10GB/month
- **GB stored**: Should stay < 1GB

## Support Contacts

- **Firebase Issues**: Firebase Console → Support
- **Vercel Issues**: Vercel Dashboard → Help
- **Code Issues**: GitHub Issues

---

## Quick Commands Reference

```bash
# Start dev server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Deploy Firebase rules only
firebase deploy --only database

# Check git status
git status

# Push to production
git push origin main
```

## Environment Variables (Vercel)

Already configured (no changes needed):
- `VITE_FIREBASE_API_KEY`
- `VITE_FIREBASE_AUTH_DOMAIN`
- `VITE_FIREBASE_PROJECT_ID`
- `VITE_FIREBASE_STORAGE_BUCKET`
- `VITE_FIREBASE_MESSAGING_SENDER_ID`
- `VITE_FIREBASE_APP_ID`
- `VITE_FIREBASE_DATABASE_URL`

---

**Last Updated**: 2024  
**Version**: 1.0.0
