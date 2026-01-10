# Supabase Setup for Community Data Collection

## 1. Create Supabase Project

1. Go to https://supabase.com
2. Click "Start your project"
3. Create a new organization (or use existing)
4. Create a new project:
   - Name: `fret-not-community` (or your preference)
   - Database Password: (generate strong password - save it!)
   - Region: Choose closest to your users (e.g., US East)
   - Pricing: Free tier is fine

5. Wait for project to finish setting up (~2 minutes)

## 2. Get Your Credentials

Once project is ready:

1. Go to Project Settings > API
2. Copy these values (you'll need them for Netlify):
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGc...` (long string starting with eyJ)
   - **service_role key**: `eyJhbGc...` (different long string - keep this secret!)





## 3. Create Database Schema

1. In Supabase dashboard, click "SQL Editor" in sidebar
2. Click "New Query"
3. Paste this SQL and click "Run":

```sql
-- Song contributions table (anonymous data collection for v1.3)
CREATE TABLE song_contributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  spotify_track_id TEXT NOT NULL,

  -- Song metadata (for reference)
  song_title TEXT NOT NULL,
  artist_name TEXT NOT NULL,

  -- User-contributed guitar data
  chords TEXT[],
  capo_position INT CHECK (capo_position >= 0 AND capo_position <= 12),
  tuning TEXT DEFAULT 'EADGBE',

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  is_anonymous BOOLEAN DEFAULT TRUE
);

-- Create indexes for fast lookups (separate from table creation)
CREATE INDEX idx_spotify_track_id ON song_contributions(spotify_track_id);
CREATE INDEX idx_created_at ON song_contributions(created_at DESC);

-- Enable Row Level Security (security requirement)
ALTER TABLE song_contributions ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous inserts (for v1.3 data collection)
CREATE POLICY "Allow anonymous contributions"
  ON song_contributions
  FOR INSERT
  TO anon
  WITH CHECK (is_anonymous = true);

-- Policy: Allow public reads (for future premium feature)
CREATE POLICY "Allow public reads"
  ON song_contributions
  FOR SELECT
  TO anon
  USING (true);

-- Analytics events table (anonymous usage tracking)
CREATE TABLE usage_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,
  event_metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for analytics queries
CREATE INDEX idx_event_type ON usage_events(event_type);
CREATE INDEX idx_events_created_at ON usage_events(created_at DESC);

-- Enable Row Level Security
ALTER TABLE usage_events ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anonymous inserts
CREATE POLICY "Allow anonymous event tracking"
  ON usage_events
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Policy: Allow public reads (for analytics dashboard)
CREATE POLICY "Allow public event reads"
  ON usage_events
  FOR SELECT
  TO anon
  USING (true);
```

4. You should see "Success. No rows returned"

## 4. Verify Setup

1. Click "Table Editor" in sidebar
2. You should see `song_contributions` table
3. It should have 0 rows

## 5. Add Environment Variables to Netlify

1. Go to your Netlify dashboard
2. Go to Site Configuration > Environment Variables
3. Add these three new variables:

```
SUPABASE_URL = https://xxxxx.supabase.co
SUPABASE_ANON_KEY = eyJhbGc... (your anon key)
SUPABASE_SERVICE_KEY = eyJhbGc... (your service role key)
```

**Important:** The service role key is SECRET - never commit it to git!

## Done!

Your Supabase database is ready. Once you add the environment variables to Netlify, the Netlify function will be able to write anonymous contributions to the database.

## Monitoring Data Collection

To see collected data:
1. Go to Supabase Table Editor
2. Click on `song_contributions`
3. View all anonymous contributions

You can also query in SQL Editor:
```sql
-- See total contributions
SELECT COUNT(*) FROM song_contributions;

-- See contributions per song
SELECT
  song_title,
  artist_name,
  COUNT(*) as contribution_count
FROM song_contributions
GROUP BY song_title, artist_name
ORDER BY contribution_count DESC
LIMIT 10;

-- View analytics events
SELECT COUNT(*) FROM usage_events;

-- Events by type (last 7 days)
SELECT
  event_type,
  COUNT(*) as event_count
FROM usage_events
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY event_type
ORDER BY event_count DESC;

-- Song entry methods (manual vs Spotify)
SELECT
  event_metadata->>'source' as source,
  COUNT(*) as count
FROM usage_events
WHERE event_type = 'song_added'
GROUP BY source;

-- Custom chord creation stats
SELECT
  COUNT(*) as total_custom_chords,
  COUNT(DISTINCT DATE(created_at)) as days_with_activity
FROM usage_events
WHERE event_type = 'custom_chord_created';

-- Strumming pattern usage
SELECT COUNT(*) as total_patterns_added
FROM usage_events
WHERE event_type = 'strumming_pattern_added';

-- Notes usage
SELECT COUNT(*) as songs_with_notes
FROM usage_events
WHERE event_type = 'notes_added';

-- Feature adoption (% of songs with each feature)
SELECT
  SUM(CASE WHEN event_type = 'song_added' THEN 1 ELSE 0 END) as total_songs,
  SUM(CASE WHEN event_type = 'notes_added' THEN 1 ELSE 0 END) as songs_with_notes,
  SUM(CASE WHEN event_type = 'strumming_pattern_added' THEN 1 ELSE 0 END) as songs_with_patterns,
  SUM(CASE WHEN event_type = 'custom_chord_created' THEN 1 ELSE 0 END) as custom_chords_created
FROM usage_events;
```










  1. Set Up Supabase (~15 mins)

  Read SUPABASE_SETUP.md - step-by-step instructions to:
  - Create free Supabase project
  - Run SQL schema
  - Get credentials

  2. Deploy (~10 mins)

  npm install  # Install Supabase dependency
  Then add these to Netlify env vars:
  - SUPABASE_URL
  - SUPABASE_ANON_KEY
  - SUPABASE_SERVICE_KEY

  3. Test (~15 mins)

  Follow the testing checklist in V1.3_DATA_COLLECTION_SUMMARY.md
