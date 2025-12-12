# Vercel Deployment Guide - Apartment Café

## Quick Start

### 1. Prerequisites
- [Vercel Account](https://vercel.com) (free)
- GitHub account (code already pushed to https://github.com/Impact-10/FoodVendor)
- Firebase credentials (from Firebase Console)

### 2. Deploy in 3 Steps

#### Step 1: Import Project
1. Go to [vercel.com/new](https://vercel.com/new)
2. Click "Import Git Repository"
3. Paste: `https://github.com/Impact-10/FoodVendor.git`
4. Click "Continue"

#### Step 2: Configure Project
1. **Project Name**: Keep as `foodvendor` (or rename as desired)
2. **Framework Preset**: Select **Vite**
3. **Root Directory**: Click "Edit" → Select `food/` → Confirm

#### Step 3: Add Environment Variables
1. Scroll to "Environment Variables"
2. Add all required VITE_ variables:

```
VITE_FIREBASE_API_KEY=AIzaSyCVGJkGudLVlzJHRE4JACqEcE--Qxonpe8
VITE_FIREBASE_AUTH_DOMAIN=apartment-fv.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=apartment-fv
VITE_FIREBASE_STORAGE_BUCKET=apartment-fv.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=176790456882
VITE_FIREBASE_APP_ID=1:176790456882:web:531dec259ece9244e1ca2b
VITE_FIREBASE_MEASUREMENT_ID=G-MTDBNYKWGP
VITE_FIREBASE_DATABASE_URL=https://apartment-fv-default-rtdb.firebaseio.com
```

3. Click **Deploy**

### Deployment Complete! ✅

Your site will be live at: `https://<project-name>.vercel.app`

Example: `https://foodvendor.vercel.app`

---

## Detailed Configuration

### Build Settings (Auto-detected)
- **Framework**: Vite
- **Build Command**: `vite build` ✓
- **Output Directory**: `dist` ✓
- **Install Command**: `npm install` ✓

These should auto-detect correctly with Vite.

### Environment Variables Reference

**For Production (Vercel Dashboard):**
1. Project Settings → Environment Variables
2. Add all 8 VITE_ variables (see above)
3. Set scope to: Production (and Preview if desired)

**Local Development (.env.local):**
```
VITE_FIREBASE_API_KEY=AIzaSyCVGJkGudLVlzJHRE4JACqEcE--Qxonpe8
VITE_FIREBASE_AUTH_DOMAIN=apartment-fv.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=apartment-fv
VITE_FIREBASE_STORAGE_BUCKET=apartment-fv.firebasestorage.app
VITE_FIREBASE_MESSAGING_SENDER_ID=176790456882
VITE_FIREBASE_APP_ID=1:176790456882:web:531dec259ece9244e1ca2b
VITE_FIREBASE_MEASUREMENT_ID=G-MTDBNYKWGP
VITE_FIREBASE_DATABASE_URL=https://apartment-fv-default-rtdb.firebaseio.com
```

⚠️ **NEVER commit .env.local!** It's in .gitignore.

### Root Directory Setup

The `food/` folder is the root of your Vite app:
```
FoodVendor/
├── flutter-app/          ← Flutter mobile app
└── food/                 ← Web app (deploy this)
    ├── src/
    ├── public/
    ├── package.json
    ├── vite.config.js
    ├── index.html
    └── dist/             ← Build output
```

**Vercel Root Directory must be set to: `food/`**

---

## Post-Deployment Verification

### Check Build Logs
1. Go to Vercel Dashboard
2. Project → Deployments → Latest
3. Click "Build Logs" to verify:
   - ✅ `npm install` succeeded
   - ✅ `vite build` completed
   - ✅ No build errors

### Test the Site
1. Visit deployment URL
2. Load menu (should show items from Firebase RTDB)
3. Add item to cart
4. Check cart modal (should be responsive on mobile)
5. Test mobile view via DevTools (Ctrl+Shift+M)

### Verify Environment Variables
Open browser console (F12):
```javascript
console.log(import.meta.env.VITE_FIREBASE_PROJECT_ID);
// Should log: "apartment-fv"
```

If it shows `undefined`, environment variables weren't set in Vercel.

---

## Continuous Deployment

### Auto-Deploy on Push
Vercel automatically deploys when you push to GitHub:

```bash
# After making changes locally
git add .
git commit -m "feat: Update menu styling"
git push origin main

# Vercel will:
# 1. Detect the push
# 2. Clone the repo
# 3. Install dependencies
# 4. Build (`vite build`)
# 5. Deploy to Vercel CDN
# Takes ~2-3 minutes
```

### View Deployment Status
- **Dashboard**: [vercel.com/dashboard](https://vercel.com/dashboard)
- Check "Deployments" tab for status
- Green ✅ = Live
- Yellow ⏳ = Building
- Red ❌ = Failed (check logs)

---

## Custom Domain Setup

### Add Custom Domain
1. Vercel Dashboard → Project → Settings
2. Domains → Add Domain
3. Enter your domain (e.g., `apartmentcafe.com`)
4. Follow DNS setup instructions

Example setup:
- Domain: `apartmentcafe.com`
- Points to: `cname.vercel.com.`
- Auto-renews with HTTPS ✓

---

## Troubleshooting

### Build Fails: "Cannot find module"
**Solution**: Run `npm install` locally
```bash
cd food/
npm install
git add package-lock.json
git commit -m "chore: update lockfile"
git push
```

### Build Fails: "import.meta.env.VITE_* is undefined"
**Solution**: Add missing environment variables in Vercel Dashboard
1. Project Settings → Environment Variables
2. Add all 8 VITE_ variables
3. Redeploy (click "Redeploy" on latest deployment)

### Deployment URL shows blank page
**Solution**: Check browser console for errors (F12)
- Firebase auth errors? Check API keys
- 404 on resources? Check build output
- Check "Build Logs" in Vercel

### Site works locally but not on Vercel
**Solution**: Test production build locally
```bash
npm run build
npm run preview
# Visit http://localhost:4173
```

---

## Performance Optimization

### Vercel Best Practices
- ✅ CSS minified automatically (Vite)
- ✅ JavaScript minified automatically (Vite)
- ✅ Images optimized by Vercel CDN
- ✅ HTTP/2 and Brotli compression enabled
- ✅ Global edge caching

### Check Performance
1. Deploy complete
2. Lighthouse (Chrome DevTools → Lighthouse → Generate report)
3. Target scores:
   - Performance: > 90
   - Accessibility: > 95
   - Best Practices: > 90
   - SEO: > 90

---

## Rollback to Previous Version

If deployment breaks:
1. Vercel Dashboard → Deployments
2. Find last working deployment
3. Click "..." → "Promote to Production"
4. Site reverts instantly

---

## Environment-Specific Builds

### Preview Deployments (for Pull Requests)
- Vercel auto-deploys each PR to unique URL
- Test changes before merging
- Once merged to main, auto-deploys to production

### Production
- All pushes to `main` branch deploy to production
- Auto-HTTPS and CDN enabled
- Can monitor usage in Analytics dashboard

---

## Monitoring & Analytics

### View Site Analytics
1. Vercel Dashboard → Project
2. Analytics tab shows:
   - Page views
   - Unique visitors
   - Top pages
   - Response times

### Error Tracking
1. Function Logs tab shows:
   - Build errors
   - Runtime errors
   - Firebase errors

---

## Useful Vercel Commands

### CLI Setup (Optional)
```bash
npm install -g vercel
vercel login
vercel --prod  # Deploy current folder
vercel env pull  # Pull env vars locally
```

### Deploy via CLI
```bash
cd food/
vercel --prod
# Interactive setup for first deploy
```

---

## GitHub Integration

### Automatic Deployments
Already configured! Every push to GitHub automatically triggers:
1. Build
2. Deploy
3. Live in 2-3 minutes

### Disconnect GitHub
If needed (not recommended):
1. Vercel Dashboard → Settings → Git
2. Click "Disconnect"

### Reconnect
1. Vercel Dashboard → Settings → Git
2. Click "Connect" and authorize GitHub

---

## Cost & Limits

### Free Plan (More than enough)
- Unlimited projects
- Unlimited deployments
- 100 GB bandwidth/month
- No credit card required
- Perfect for this project

### Upgrade if needed
- Pro: $20/month (higher limits)
- Enterprise: Custom (large-scale)

---

## Next Steps

1. ✅ Code pushed to GitHub
2. ✅ Ready for Vercel deployment
3. ⏭️ **Now Deploy to Vercel** (follow Quick Start above)
4. Test on phone once live
5. Share URL with users: `https://<your-project>.vercel.app`

---

## Support Resources

- [Vercel Docs](https://vercel.com/docs)
- [Vite + Vercel Guide](https://vitejs.dev/guide/deploy#vercel)
- [Firebase on Vercel](https://vercel.com/docs/integrations/firebase)
- [Troubleshooting Guide](https://vercel.com/support)

---

**Last Updated**: December 2025  
**Status**: ✅ Ready for Deployment  
**GitHub**: https://github.com/Impact-10/FoodVendor  
**Firebase Project**: apartment-fv (Spark plan)
