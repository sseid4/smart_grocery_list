# Smart Grocery List

A lightweight Flutter app to build and manage grocery lists, grouped by categories, with a weekly generator and template saving.

Features
 - Add, edit and delete grocery items (quantity, price, category, priority)
 - Quick-add presets for common items
 - Categories screen with expandable lists
 - Weekly generator with saveable templates
 - Persistent storage for items and templates (SQLite)
 - Persisted settings (dark mode, notifications) via SharedPreferences


Architecture notes
 - `lib/services/db_helper.dart` — SQLite helper and schema
 - `lib/services/in_memory_repo.dart` — in-memory cache using `ValueNotifier` and convenience methods. Loads items/templates from DB on startup.
 - `lib/services/settings_service.dart` — SharedPreferences-backed settings exposed via `ValueNotifier`
 - `lib/screens/*` — Screens for Home, Add/Edit, Categories, Weekly generator, Templates, Settings

Persistence
 - Items and templates are persisted in `smart_grocery.db` (app documents directory).
 - Settings are saved in SharedPreferences.

Notes
 - The project uses a ValueNotifier-based in-memory store for simplicity. If you prefer a more structured state-management approach, migrating to Provider/ChangeNotifier or Riverpod is straightforward.
 - Running `flutter analyze` will show a few informational lints about deprecated APIs (some widgets migrated away from deprecated Radio APIs).

If you'd like, I can add a CONTRIBUTING.md, a CHANGELOG.md, or CI configuration next.
