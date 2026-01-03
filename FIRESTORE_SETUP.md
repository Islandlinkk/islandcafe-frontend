# Firestore Setup Instructions

## Deploy Security Rules

To fix the permission-denied error, you need to deploy the Firestore security rules to your Firebase project.

### Option 1: Using Firebase CLI

1. Install Firebase CLI if you haven't:
```bash
npm install -g firebase-tools
```

2. Login to Firebase:
```bash
firebase login
```

3. Initialize Firebase (if not already done):
```bash
firebase init firestore
```

4. Deploy the rules:
```bash
firebase deploy --only firestore:rules
```

### Option 2: Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `islandcoffeeapp-62b47`
3. Navigate to **Firestore Database** → **Rules** tab
4. Copy and paste the contents of `firestore.rules` file
5. Click **Publish**

## Create Composite Index (Required)

The orders query uses both `where` and `orderBy`, which requires a composite index.

### Option 1: Auto-create from Error Link

When you run the app and see an error, Firebase will provide a link to create the index automatically. Click that link.

### Option 2: Manual Creation

1. Go to Firebase Console → Firestore Database → Indexes
2. Click **Create Index**
3. Set:
   - Collection ID: `orders`
   - Fields to index:
     - `userId` (Ascending)
     - `orderDate` (Descending)
4. Click **Create**

## Security Rules Summary

The rules allow:
- ✅ Users to read/write their own user documents
- ✅ Users to read/create/update their own orders
- ✅ Users to read/create/update their own feedback
- ❌ All other operations are denied

## Testing

After deploying rules:
1. Make sure you're logged in
2. Try accessing the History screen
3. The permission error should be resolved

