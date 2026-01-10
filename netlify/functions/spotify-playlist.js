// Netlify Function to fetch Spotify playlist tracks
exports.handler = async function(event, context) {
  const clientId = process.env.SPOTIFY_CLIENT_ID;
  const clientSecret = process.env.SPOTIFY_CLIENT_SECRET;
  
  // Get playlist ID from URL parameters
  const playlistId = event.queryStringParameters?.id;
  
  if (!playlistId) {
    return {
      statusCode: 400,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ error: 'Playlist ID parameter required' })
    };
  }

  if (!clientId || !clientSecret) {
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ error: 'Spotify credentials not configured' })
    };
  }

  try {
    // First, get access token
    const tokenResponse = await fetch('https://accounts.spotify.com/api/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ' + Buffer.from(clientId + ':' + clientSecret).toString('base64')
      },
      body: 'grant_type=client_credentials'
    });

    const tokenData = await tokenResponse.json();
    const accessToken = tokenData.access_token;

    // Fetch all tracks from playlist (handle pagination)
    let allTracks = [];
    let nextUrl = `https://api.spotify.com/v1/playlists/${playlistId}/tracks?limit=50`;

    while (nextUrl) {
      const tracksResponse = await fetch(nextUrl, {
        headers: {
          'Authorization': `Bearer ${accessToken}`
        }
      });

      const tracksData = await tracksResponse.json();
      
      // Add valid tracks to our array
      if (tracksData.items) {
        const validTracks = tracksData.items
          .map(item => item.track)
          .filter(track => track !== null && track !== undefined);
        allTracks = allTracks.concat(validTracks);
      }

      nextUrl = tracksData.next;
    }

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        items: allTracks.map(track => ({
          track: track
        })),
        total: allTracks.length
      })
    };
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ error: error.message })
    };
  }
};

