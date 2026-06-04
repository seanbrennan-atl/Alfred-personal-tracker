# Weekly Tracker — Setup Guide
Cross-device sync (iPhone + Desktop) via Firebase + GitHub Pages

---

## Part 1 — Host the app on GitHub Pages

This gives you a permanent URL that works on any device.

1. Go to [github.com](https://github.com) and sign in
2. Click **+** (top right) → **New repository**
   - Name: `weekly-tracker` (or anything you like)
   - Set to **Public**
   - Click **Create repository**
3. Click **uploading an existing file** on the next screen
4. Drag `weekly-tracker.html` onto the page, then rename it to **`index.html`** in the filename field before uploading
5. Click **Commit changes**
6. Go to **Settings** → **Pages** (left sidebar)
7. Under "Branch", select **main** and **/ (root)** → click **Save**
8. Wait about 60 seconds, then your app is live at:
   `https://your-github-username.github.io/weekly-tracker/`

---

## Part 2 — Set up Firebase (cloud sync)

Firebase stores your data so it syncs between your iPhone and desktop.

### Create a Firebase project

1. Go to [console.firebase.google.com](https://console.firebase.google.com) and sign in with your Google account
2. Click **Create a project** → give it any name (e.g. "Weekly Tracker") → Continue
3. Disable Google Analytics when asked → **Create project**

### Add a web app

4. On the project overview page, click the **`</>`** (Web) icon
5. Give the app a nickname (e.g. "weekly-tracker") → click **Register app**
6. You'll see a code block like this — **copy just the config object**:
   ```js
   const firebaseConfig = {
     apiKey: "AIza...",
     authDomain: "your-project.firebaseapp.com",
     databaseURL: "https://your-project-default-rtdb.firebaseio.com",
     projectId: "your-project",
     storageBucket: "your-project.appspot.com",
     messagingSenderId: "123456789",
     appId: "1:123:web:abc"
   };
   ```
7. Click **Continue to console**

### Enable Realtime Database

8. In the left sidebar: **Build → Realtime Database**
9. Click **Create database**
10. Choose a region (US Central is fine) → **Next**
11. Select **Start in test mode** → **Enable**
12. After it's created, go to the **Rules** tab and replace the rules with:
    ```json
    {
      "rules": {
        "u": {
          "$uid": {
            ".read": "$uid === auth.uid",
            ".write": "$uid === auth.uid"
          }
        }
      }
    }
    ```
13. Click **Publish**

### Enable Google Sign-In

14. In the left sidebar: **Build → Authentication**
15. Click **Get started**
16. Click **Google** → toggle **Enable** → enter your email as the support email → **Save**

### Authorize your GitHub Pages domain

17. Still in Authentication, click the **Settings** tab
18. Scroll to **Authorized domains** → click **Add domain**
19. Enter: `your-github-username.github.io` → **Add**

---

## Part 3 — Connect the app to Firebase

1. Open your app in a browser: `https://your-github-username.github.io/weekly-tracker/`
2. You'll see a **"Set up cloud sync"** screen
3. Paste the `firebaseConfig` object you copied in Step 6 above
4. Click **Save & Connect**
5. The page reloads and asks you to **Sign in with Google** — sign in with the same Google account you used for Firebase
6. Done! You'll see **· Synced** under "Weekly Tracker" in the header

---

## Part 4 — Add to iPhone home screen

1. Open Safari on your iPhone (must be Safari, not Chrome)
2. Navigate to `https://your-github-username.github.io/weekly-tracker/`
3. Tap the **Share** button (box with arrow) at the bottom
4. Scroll down and tap **Add to Home Screen**
5. Tap **Add**

The app now appears on your home screen and opens full-screen like a native app. Sign in with Google when prompted — it'll use the same Firebase account and sync automatically.

---

## How sync works

- **On open**: the app checks whether your phone or your desktop has the most recently saved data and loads the newer copy
- **On every change**: data is pushed to Firebase immediately
- Works offline — changes save locally and sync the next time you're connected

---

## Troubleshooting

| Problem | Fix |
|---|---|
| "· Offline" in header | Check your internet connection; data is still saved locally |
| Sign-in redirects loop | Make sure your GitHub Pages domain is in Firebase's Authorized Domains list |
| Setup screen appears again | Your Firebase config may have an error — re-paste the full config object |
| Need to reset Firebase config | Open browser console and run `resetFbConfig()` |
| App shows old data after sync | Your local data was newer — Firebase only overwrites if remote is more recent |

---

## Updating the app in the future

When there's a new version of `weekly-tracker.html`:
1. Rename the new file to `index.html`
2. Go to your GitHub repo → click `index.html` → click the pencil (Edit) icon → or drag and drop the new file
3. Commit the changes — GitHub Pages updates automatically within ~60 seconds
4. Your Firebase data is untouched; it syncs right back in on next open
