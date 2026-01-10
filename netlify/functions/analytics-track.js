/**
 * Netlify Function: analytics-track
 *
 * Accepts anonymous usage events and stores them in Supabase.
 * Privacy-friendly analytics - no user IDs, just event types and metadata.
 *
 * POST /analytics-track
 * Body: {
 *   eventType: string,
 *   eventMetadata?: object
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
    const { eventType, eventMetadata } = JSON.parse(event.body);

    // Validate required fields
    if (!eventType || typeof eventType !== 'string') {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'eventType is required and must be a string' })
      };
    }

    // Validate event type against allowed values
    const allowedEventTypes = [
      'song_added',
      'custom_chord_created',
      'chord_suggestion_applied',
      'song_transposed',
      'tuner_opened',
      'strumming_pattern_added',
      'notes_added'
    ];

    if (!allowedEventTypes.includes(eventType)) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Invalid event type', allowedTypes: allowedEventTypes })
      };
    }

    // Initialize Supabase client
    const supabase = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    );

    // Insert event into database
    const { data, error } = await supabase
      .from('usage_events')
      .insert({
        event_type: eventType,
        event_metadata: eventMetadata || {},
        created_at: new Date().toISOString()
      })
      .select()
      .single();

    if (error) {
      console.error('Supabase error:', error);
      return {
        statusCode: 500,
        body: JSON.stringify({ error: 'Failed to save event', details: error.message })
      };
    }

    return {
      statusCode: 200,
      body: JSON.stringify({
        success: true,
        message: 'Event tracked successfully'
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
