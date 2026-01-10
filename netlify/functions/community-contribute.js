/**
 * Netlify Function: community-contribute
 *
 * Accepts anonymous song contributions and stores them in Supabase.
 * Used in v1.3 for silent data collection (no user-facing features yet).
 *
 * POST /community-contribute
 * Body: {
 *   spotifyTrackId: string,
 *   songTitle: string,
 *   artist: string,
 *   chords: string[],
 *   capo: number,
 *   tuning: string
 * }
 */

const { createClient } = require('@supabase/supabase-js');

exports.handler = async function(event, context) {
  // Only allow POST requests
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method Not Allowed' })
    };
  }

  try {
    // Parse request body
    const contribution = JSON.parse(event.body);

    // Validate required fields
    const errors = validateContribution(contribution);
    if (errors.length > 0) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Validation failed', errors })
      };
    }

    // Initialize Supabase client
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY  // Using anon key for anonymous contributions
    );

    // Insert contribution into database
    const { data, error } = await supabase
      .from('song_contributions')
      .insert({
        spotify_track_id: contribution.spotifyTrackId,
        song_title: contribution.songTitle,
        artist_name: contribution.artist,
        chords: contribution.chords,
        capo_position: contribution.capo,
        tuning: contribution.tuning || 'EADGBE',
        is_anonymous: true,
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      console.error('Supabase error:', error);
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Failed to save contribution', details: error.message })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Contribution saved anonymously',
        contributionId: data.id
      })
    };

  } catch (error) {
    console.error('Function error:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error', message: error.message })
    };
  }
};

/**
 * Validates the contribution data
 */
function validateContribution(data) {
  const errors = [];

  // Required fields
  if (!data.spotifyTrackId || typeof data.spotifyTrackId !== 'string') {
    errors.push('spotifyTrackId is required and must be a string');
  }

  if (!data.songTitle || typeof data.songTitle !== 'string') {
    errors.push('songTitle is required and must be a string');
  }

  if (!data.artist || typeof data.artist !== 'string') {
    errors.push('artist is required and must be a string');
  }

  // Chords validation
  if (!Array.isArray(data.chords)) {
    errors.push('chords must be an array');
  } else if (data.chords.length === 0) {
    errors.push('chords array cannot be empty');
  } else if (!data.chords.every(chord => typeof chord === 'string')) {
    errors.push('all chords must be strings');
  }

  // Capo validation
  if (typeof data.capo !== 'number') {
    errors.push('capo must be a number');
  } else if (data.capo < 0 || data.capo > 12) {
    errors.push('capo must be between 0 and 12');
  }

  // Tuning validation (optional)
  if (data.tuning && typeof data.tuning !== 'string') {
    errors.push('tuning must be a string');
  }

  // Spotify track ID format validation
  if (data.spotifyTrackId && !/^[a-zA-Z0-9]{22}$/.test(data.spotifyTrackId)) {
    errors.push('spotifyTrackId must be a valid Spotify track ID (22 alphanumeric characters)');
  }

  return errors;
}
