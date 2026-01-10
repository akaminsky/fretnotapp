# Spotify API Setup Guide

To enable full Spotify search functionality, you need to set up a Spotify Developer account and configure the API credentials.

## Step 1: Create Spotify Developer Account

1. Go to [Spotify for Developers](https://developer.spotify.com/)
2. Click "Log In" and sign in with your Spotify account
3. Click "Create App" in the Dashboard
4. Fill in the app details:
   - **App Name**: "My Guitar Songbook" (or any name you prefer)
   - **App Description**: "Guitar song tracker with Spotify integration"
   - **Website**: Your website URL (optional)
   - **Redirect URI**: `http://localhost:3000` (for development)
   - **API/SDKs**: Check "Web API"
5. Click "Save"

## Step 2: Get Your Credentials

1. In your app dashboard, click on your app
2. Copy the **Client ID** from the app settings
3. Click "Show Client Secret" and copy the **Client Secret**

## Step 3: Configure the App

### Option A: Simple Setup (Demo Mode)
The app currently works in demo mode with sample data. No configuration needed for basic functionality.

### Option B: Full Spotify Integration
To enable real Spotify search:

1. **Update the Client ID** in `script.js`:
   ```javascript
   this.spotifyClientId = 'YOUR_ACTUAL_CLIENT_ID_HERE';
   ```

2. **Add OAuth Flow** (Advanced):
   For production use, you'll need to implement the Spotify OAuth flow. This requires:
   - A backend server to handle authentication
   - Proper redirect URI configuration
   - Token management

## Step 4: Development vs Production

### Development
- Use `http://localhost:3000` as redirect URI
- Test with sample data (current implementation)

### Production
- Use your actual domain as redirect URI
- Implement proper OAuth flow
- Consider using a backend service for token management

## Current Implementation

The app currently includes:

✅ **Demo Mode**: Works with sample data for testing
✅ **Manual Entry**: Users can still add songs manually
✅ **Spotify URLs**: Can add Spotify URLs manually
✅ **Search Interface**: Beautiful search UI ready for integration

## Features Available Now

1. **Search Interface**: Beautiful Spotify-themed search section
2. **Auto-Population**: When you select a song, it auto-fills:
   - Song title
   - Artist name
   - Spotify URL
3. **Manual Entry**: Users can still add songs manually
4. **Demo Data**: Sample songs for testing the interface

## Next Steps for Full Integration

1. **Set up Spotify Developer Account** (5 minutes)
2. **Get Client ID** (2 minutes)
3. **Update the code** with your Client ID
4. **Implement OAuth flow** (for production use)

## Security Notes

- Never expose your Client Secret in frontend code
- Use environment variables for production
- Implement proper token refresh logic
- Consider using a backend proxy for API calls

## Testing the Current Implementation

1. Open the app in your browser
2. Try searching for songs like "Wonderwall", "Hotel California", or "Black"
3. Select a song to see auto-population in action
4. Add your guitar chords and capo position
5. Save the song to your collection

The app is fully functional even without Spotify API credentials - it just uses demo data for the search results!
