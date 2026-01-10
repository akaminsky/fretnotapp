# Spotify API Setup Guide

## Quick Setup Steps

### Step 1: Add Your Client ID

1. Open `script.js`
2. Find this line (around line 11):
   ```javascript
   this.spotifyClientId = 'YOUR_SPOTIFY_CLIENT_ID';
   ```
3. Replace `YOUR_SPOTIFY_CLIENT_ID` with your actual Client ID

### Step 2: Add Your Client Secret (Optional for enhanced features)

1. Find this line (around line 427):
   ```javascript
   body: `grant_type=client_credentials&client_id=${this.spotifyClientId}&client_secret=YOUR_CLIENT_SECRET`
   ```
2. Replace `YOUR_CLIENT_SECRET` with your actual Client Secret

## Important Security Notes

⚠️ **WARNING**: The current implementation exposes your Client Secret in the frontend code, which is NOT recommended for production use.

### Better Approach (Recommended):

For a production app, you should:
1. **Use a Backend Server**: Create a simple backend (Node.js, Python, etc.) to handle Spotify authentication
2. **Keep Secrets Secure**: Store Client Secret on the server, not in the browser
3. **Use Environment Variables**: Never commit secrets to Git

### Simple Backend Example (Optional):

If you want to do this properly, you can create a simple backend with:
- Node.js + Express
- Python + Flask
- Netlify/Vercel Functions

## Current Features

### Without API Credentials:
- ✅ Demo search with 10 popular songs
- ✅ Manual song entry
- ✅ All guitar tracking features work

### With Client ID Only:
- ⚠️ Limited - needs Client Secret for full authentication

### With Client ID + Client Secret:
- ✅ Full Spotify search
- ✅ Real-time song data
- ✅ Album artwork
- ✅ Millions of songs available

## Alternative: Keep Using Demo Mode

The app works great in demo mode! You can:
- Use the 10 demo songs for testing
- Manually enter any song you want
- All features work without Spotify API

## Testing Your Setup

1. Open the app in your browser
2. Open Developer Console (F12)
3. Look for:
   - `Spotify authenticated successfully` ✅ (API working)
   - `Using demo mode` ℹ️ (Using demo data)
4. Try searching for a song
5. Check if you get real results or demo results

## Need Help?

If you're getting errors:
1. Check Developer Console (F12) for error messages
2. Verify your Client ID is correct
3. Make sure you've replaced both placeholders
4. Try searching for a popular song first

## What to Do Next

Choose one of these options:

### Option 1: Use Demo Mode (Easiest)
- Just leave it as is
- Manually add songs
- Works perfectly for personal use

### Option 2: Add Client ID Only (Simple)
- Add your Client ID
- Still uses demo mode (Client Secret needed)
- Good for testing

### Option 3: Full Setup (Best, but more complex)
- Create a backend server
- Handle authentication securely
- Full Spotify integration

For most personal use cases, **Option 1 (Demo Mode)** is perfectly fine!
