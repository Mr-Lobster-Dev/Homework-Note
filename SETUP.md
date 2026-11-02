# Turn on Google sign-in and sync

Homework Note works without this: items are saved on the device. Follow these steps once to let people sign in with Google and see the same items on every device. It's free for personal use.

## 1. Create a Firebase project

1. Go to https://console.firebase.google.com and choose **Add project**.
2. Name it (for example "Homework Note"). You can turn Google Analytics off.

## 2. Turn on Google sign-in

1. In the project, open **Build → Authentication** and choose **Get started**.
2. Under **Sign-in method**, choose **Google**, switch it on, pick a support email, and **Save**.

## 3. Create the database

1. Open **Build → Firestore Database** and choose **Create database**.
2. Pick a location close to you and start in **production mode**.
3. Open the **Rules** tab, replace everything with the rules below, and choose **Publish**. They let each person read and write only their own items.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/items/{itemId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 4. Approve your website address

Open **Authentication → Settings → Authorized domains** and choose **Add domain** for each address where the app runs, for example `your-project.vercel.app`. `localhost` is already approved.

## 5. Paste your settings into the app

1. In **Project settings** (the gear icon), under **Your apps**, choose the web icon `</>` and register an app.
2. Copy the `apiKey`, `authDomain`, `projectId` and `appId` values into `firebase-config.js`.
3. Commit and push. Vercel redeploys on its own.

Open the app and tap the person icon at the top right to sign in.

## Good to know

- Items sync between devices. Photos, videos and PDFs stay on the device where you added them, because storing files costs money in Firebase. Links sync.
- Items you saved on a device before signing in are added to your account the first time you sign in.
- Signing out removes the synced items from that device. They stay in your account.
