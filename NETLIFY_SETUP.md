# Netlify Setup Guide for Spotify Backend

This guide will walk you through setting up Netlify to securely handle Spotify API authentication for your iOS app.

## Prerequisites

- A GitHub account
- A Spotify Developer account with an app created
- Your Spotify Client ID and Client Secret

## Step 1: Create a Spotify Developer App

If you haven't already:

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Click "Create App"
3. Fill in:
   - **App name**: "Fret Not" (or any name)
   - **App description**: "Guitar songbook app"
   - **Website**: Your website (optional)
   - **Redirect URI**: `https://your-netlify-site.netlify.app/callback` (we'll update this after Netlify setup)
4. Click "Save"
5. Copy your **Client ID** and **Client Secret** (click "Show Client Secret")

## Step 2: Prepare Your Code for Netlify

Your Netlify functions are already set up in the `netlify/functions/` directory:

- `spotify-token.js` - Gets access tokens
- `spotify-search.js` - Searches for tracks
- `spotify-playlist.js` - Fetches playlist tracks

## Step 3: Deploy to Netlify

### Option A: Deploy via GitHub (Recommended)

1. **Push your code to GitHub:**
   ```bash
   cd /Users/akaminsky/code/akaminsky.github.io/ai/guitar
   git init  # if not already a git repo
   git add .
   git commit -m "Initial commit with Netlify functions"
   git remote add origin YOUR_GITHUB_REPO_URL
   git push -u origin main
   ```

2. **Go to Netlify:**
   - Visit [netlify.com](https://netlify.com)
   - Sign up/Log in with your GitHub account
   - Click "Add new site" → "Import an existing project"
   - Select your GitHub repository
   - Configure build settings:
     - **Base directory**: `ai/guitar` (or leave blank if repo root)
     - **Build command**: Leave empty (or `npm install` if needed)
     - **Publish directory**: `.` (or leave as default)
   - Click "Deploy site"

3. **Wait for deployment** (takes ~2 minutes)

4. **Copy your Netlify site URL:**
   - You'll see something like: `https://random-name-12345.netlify.app`
   - Or you can set a custom domain name in Site settings

### Option B: Deploy via Netlify CLI

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Login to Netlify:**
   ```bash
   netlify login
   ```

3. **Deploy:**
   ```bash
   cd /Users/akaminsky/code/akaminsky.github.io/ai/guitar
   netlify deploy --prod
   ```

   Follow the prompts to create a new site.

## Step 4: Configure Environment Variables

1. **In Netlify Dashboard:**
   - Go to your site
   - Click "Site settings" → "Environment variables"
   - Click "Add a variable"

2. **Add these two variables:**
   - **Key**: `SPOTIFY_CLIENT_ID`
     **Value**: Your Spotify Client ID
   
   - **Key**: `SPOTIFY_CLIENT_SECRET`
     **Value**: Your Spotify Client Secret

3. **Click "Save"**

4. **Redeploy your site:**
   - Go to "Deploys" tab
   - Click "Trigger deploy" → "Clear cache and deploy site"
   - Wait for deployment to complete

## Step 5: Update Your iOS App

1. **Open your Xcode project:**
   - Navigate to `SpotifyService.swift`

2. **Update the Netlify URL:**
   Find this line (around line 21):
   ```swift
   private let netlifyBaseURL = "YOUR_NETLIFY_SITE_URL_HERE"
   ```
   
   Replace it with your actual Netlify site URL:
   ```swift
   private let netlifyBaseURL = "https://your-site-name.netlify.app"
   ```
   
   **Important:** Don't include a trailing slash!

3. **Build and run your app**

## Step 6: Test It

1. **Test Spotify Search:**
   - Open your app
   - Try adding a new song
   - Search for a Spotify song
   - It should now use real Spotify results!

2. **Test Playlist Import:**
   - Go to Settings → Import Playlist
   - Paste a Spotify playlist URL
   - It should import all tracks

## Step 7: Update Spotify Redirect URI (Optional)

If you want to add user authentication later:

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Click on your app
3. Click "Edit Settings"
4. Under "Redirect URIs", add:
   - `https://your-netlify-site.netlify.app/callback`
5. Click "Add" and "Save"

## Troubleshooting

### Functions not working?

1. **Check function logs:**
   - In Netlify dashboard → "Functions" tab
   - Click on a function to see logs

2. **Verify environment variables:**
   - Go to "Site settings" → "Environment variables"
   - Make sure both variables are set correctly
   - Note: Variables are case-sensitive!

3. **Check function URLs:**
   - Functions should be at: `https://your-site.netlify.app/.netlify/functions/spotify-token`
   - Test in browser to see if they return data

4. **Common errors:**
   - **401 Unauthorized**: Wrong Client ID/Secret
   - **500 Error**: Check function logs in Netlify dashboard
   - **404 Not Found**: Wrong Netlify URL in iOS app

### Testing functions locally (Optional)

1. **Install Netlify CLI:**
   ```bash
   npm install -g netlify-cli
   ```

2. **Start local dev server:**
   ```bash
   cd /Users/akaminsky/code/akaminsky.github.io/ai/guitar
   netlify dev
   ```

3. **Set local environment variables:**
   Create a `.env` file in the `netlify/functions/` directory:
   ```
   SPOTIFY_CLIENT_ID=your_client_id
   SPOTIFY_CLIENT_SECRET=your_client_secret
   ```

4. **Test locally:**
   - Functions will be at `http://localhost:8888/.netlify/functions/spotify-token`
   - Update your iOS app's `netlifyBaseURL` to test locally

## Security Notes

✅ **Good:**
- Client Secret is stored on Netlify (server-side)
- Not exposed in iOS app code
- Environment variables are encrypted

⚠️ **Remember:**
- Never commit Client Secret to Git
- Don't share your Netlify site URL publicly if it contains credentials
- Consider adding rate limiting for production use

## Next Steps

Once everything is working:

1. Consider adding a custom domain to Netlify
2. Set up monitoring/analytics
3. Add error tracking (e.g., Sentry)
4. Consider caching tokens to reduce API calls

## Support

If you run into issues:
1. Check Netlify function logs
2. Check Xcode console for iOS errors
3. Verify all URLs are correct
4. Make sure environment variables are set

