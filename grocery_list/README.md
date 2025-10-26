# Smart Grocery List

A lightweight Flutter app to build and manage grocery lists, grouped by categories, with a weekly generator and template saving.

Features
 - Add, edit and delete grocery items (quantity, price, category, priority)
 - Quick-add presets for common items
 - Categories screen with expandable lists
 - Weekly generator with saveable templates
 - Persistent storage for items and templates (SQLite)
 - Persisted settings (dark mode, notifications) via SharedPreferences

Generator presets (short)
 - Balanced — favors higher-priority items but prefers cheaper items when priorities tie; good general-purpose selection.
 - Low-cost — sorts candidates by ascending price and picks the cheapest items first; use when minimizing spend.
 - Staples — prioritizes items by declared priority (High > Medium > Low), surfacing important staples regardless of price.

Controls
 - Target items: hard limit on how many items the generator will pick.
 - Budget: optional cap; when set the generator skips items that would push the running total over the budget (greedy skip, not an exact knapsack).


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


