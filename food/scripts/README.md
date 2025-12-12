# Scripts Directory

This directory contains utility scripts for managing the Apartment Café application.

## Available Scripts

### seed-data.js
Seeds the Firestore database with sample menu items.

**Prerequisites:**
1. Download your Firebase service account key:
   - Go to Firebase Console
   - Project Settings > Service Accounts
   - Click "Generate New Private Key"
   - Save as `service-account-key.json` in this directory

**Usage:**
```bash
cd scripts
npm install
npm run seed
```

This will add 14 sample menu items across all meal types (breakfast, lunch, snack, dinner).

## Adding More Scripts

You can add more utility scripts here for:
- Bulk operations on orders
- Analytics reports
- Data migrations
- Backup/restore operations
