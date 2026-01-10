// Netlify Function to get audio features for a track using SoundNet Track Analysis API
exports.handler = async function(event, context) {
  const rapidApiKey = process.env.RAPIDAPI_KEY;

  // Get trackId from URL parameters
  const trackId = event.queryStringParameters.trackId;

  if (!trackId) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'trackId parameter required' })
    };
  }

  if (!rapidApiKey) {
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'RapidAPI key not configured' })
    };
  }

  try {
    // Call SoundNet Track Analysis API with Spotify track ID
    const soundNetResponse = await fetch(
      `https://track-analysis.p.rapidapi.com/pktx/spotify/${trackId}`,
      {
        method: 'GET',
        headers: {
          'x-rapidapi-key': rapidApiKey,
          'x-rapidapi-host': 'track-analysis.p.rapidapi.com'
        }
      }
    );

    if (!soundNetResponse.ok) {
      const errorBody = await soundNetResponse.text();
      console.error('SoundNet API error:', soundNetResponse.status, errorBody);
      throw new Error(`SoundNet API error: ${soundNetResponse.status}`);
    }

    const soundNetData = await soundNetResponse.json();

    // Convert SoundNet format to Spotify format
    // SoundNet returns: key: "C", mode: "major"
    // Spotify expects: key: 0 (0-11), mode: 1 (0=minor, 1=major)

    const keyMap = {
      'C': 0, 'C#': 1, 'Db': 1, 'D': 2, 'D#': 3, 'Eb': 3,
      'E': 4, 'F': 5, 'F#': 6, 'Gb': 6, 'G': 7, 'G#': 8,
      'Ab': 8, 'A': 9, 'A#': 10, 'Bb': 10, 'B': 11
    };

    const convertedData = {
      key: keyMap[soundNetData.key] || 0,
      mode: soundNetData.mode === 'major' ? 1 : 0,
      tempo: soundNetData.tempo || 120,
      time_signature: 4, // SoundNet doesn't provide this, default to 4/4
      danceability: soundNetData.danceability / 100 || 0.5, // Convert 0-100 to 0-1
      energy: soundNetData.energy / 100 || 0.5,
      valence: soundNetData.happiness / 100 || 0.5, // SoundNet calls it "happiness"
      _source: 'soundnet' // Mark that this came from SoundNet
    };

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(convertedData)
    };
  } catch (error) {
    console.error('Error in audio features function:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: error.message })
    };
  }
};
