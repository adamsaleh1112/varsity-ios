# Varsity (iOS / SwiftUI)

Varsity is a SwiftUI iOS app for discovering and viewing **high school sports** information backed by **Supabase**.

The app is currently structured to move from mock UI into real, backend-connected screens:
- Schools list is fetched from Supabase Postgres (`schools`)
- Teams are fetched for a selected school (`teams`)
- Games are fetched for a selected team (`games`)
- School logos are loaded from Supabase Storage (`school-assets`) using the stored `logo_path`

## Tech Stack

- Frontend: SwiftUI
- Architecture: MVVM (async/await)
- Backend: Supabase
  - Postgres: relational data for `schools`, `teams`, `games`
  - Storage: logo files (bucket: `school-assets`)

## Current App Flow (Test UI)

The initial implementation uses a minimal test flow to verify the Supabase connection end-to-end:
1. App launches to a schools list
2. Tap a school -> navigate to teams for that school
3. Tap a team -> navigate to its games schedule

## Data Model (Supabase)

### `schools`
Stores school identity/branding metadata.

Key fields used by the app:
- `id` (UUID)
- `name`, `short_name`, `city`, `state`, `mascot`
- `primary_color`, `secondary_color`
- `logo_path` (relative path inside `school-assets`)

### `teams`
Stores athletic teams belonging to a school.

Key fields used by the app:
- `id` (UUID)
- `school_id` (FK to `schools.id`)
- `sport`, `gender`, `level`
- `display_name`
- (optional) `logo_path`

### `games`
Stores matchups between two teams with explicit home/away teams.

Key fields used by the app:
- `id` (UUID)
- `home_team_id`, `away_team_id` (FKs to `teams.id`)
- `location_school_id` (nullable; `NULL` means neutral site)
- `game_date`, `start_time`, `status`
- `home_score`, `away_score` (optional)

## Folder Structure (MVVM)

At the moment, the code is organized into:
- `Varsity/Models/` - Codable structs for Supabase rows
- `Varsity/Services/`
  - `SupabaseManager.swift` - shared Supabase client
  - `SportsDataService.swift` - queries + Storage public URL generation
- `Varsity/ViewModels/` - ObservableObject view models that load data async/await
- `Varsity/Views/` - SwiftUI screens

## Supabase Configuration

Configure your Supabase credentials in:
- `Varsity/Services/SupabaseManager.swift`

You should use:
- Supabase Project URL
- Supabase **anon public** key

Security note: the app should never use the Supabase `service_role` key from the frontend.

## Logos / Storage

School logos are loaded by combining:
- Storage bucket: `school-assets`
- Database `logo_path` (relative path)

The app generates the public URL via the Supabase Storage API and loads it with `AsyncImage`.

## Next Steps

After the end-to-end data pipeline is confirmed, the plan is to replace the temporary test UI with the screenshot-based SwiftUI implementation (layout, spacing, hierarchy, and navigation feel taken from the mockups as the visual source of truth).

