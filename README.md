# Good Eating

A food recipe app built with **Flutter**, **Cubit** (`flutter_bloc`), **Dio** and
**Clean Architecture**, on top of the free [TheMealDB](https://www.themealdb.com/api.php) API.
Browse categories, open a recipe with its ingredients, steps and video, search by name, and save
favourites that survive closing the app.

## Run

```bash
flutter pub get
flutter run
```

```bash
flutter analyze
flutter test
```

An opt-in smoke test checks the models against the live API (skipped by default):

```bash
LIVE_API=1 flutter test test/live
```

## Screens

| Tab / screen | What it does |
|---|---|
| **Welcome** | Shown once, on the first launch only. |
| **Home** | Trending, a category chip row with a selected state, Recent, Popular creators. |
| **Category grid** | Every meal in a category as a two-column grid, opened from "See all". |
| **Meal details** | Photo (hero), rating, creator, ingredients, numbered steps, YouTube video. |
| **Saved** | Hearted meals, newest first. Swipe or tap the heart to remove, with Undo. |
| **Search** | Debounced search by name; "no results" is a friendly message, not an error. |
| **Notifications**, **Profile** | Built from the design. See "What is placeholder" below. |

## Architecture

Feature-first Clean Architecture with three layers per feature and one rule: dependencies point
inwards.

```
presentation (widgets, Cubits)  ->  domain (entities, use cases, repository interfaces)  <-  data (Dio, storage, models)
```

- `lib/core`: theme tokens from the Figma file, the `Failure` / `Result` types, the Dio client,
  and widgets shared across features.
- `lib/features/<feature>`: `meals` (the API), `favorites`, `onboarding`, and presentation-only
  features (`home`, `category_meals`, `meal_details`, `search`, `profile`, `notifications`, `shell`).
- `lib/app`: dependency injection (`get_it`), routing, and `App`.

Errors never leave the data layer as exceptions: `ErrorMapper` is the single place that turns a
`DioException` into a `Failure`, and the UI shows a message with **Try again**.

Full detail: [docs/01-system-design.md](docs/01-system-design.md).

## Where each exam requirement lives

| Requirement | Where |
|---|---|
| Horizontal category list with a selected state | [`category_chips_row.dart:36`](lib/features/meals/presentation/widgets/category_chips_row.dart) (`ListView.builder`), [`category_chip.dart:38`](lib/features/meals/presentation/widgets/category_chip.dart) |
| Two-column `GridView.builder` | [`category_meals_grid.dart:41`](lib/features/category_meals/presentation/widgets/category_meals_grid.dart) (two columns set at line 13) |
| Loading, success and error states with a retry button | `DataState` in [`core/state`](lib/core/state/data_state.dart), [`AppErrorView`](lib/core/widgets/app_error_view.dart), skeletons in each screen |
| Models with `fromJson`, null safety | [`meal_detail_model.dart:26`](lib/features/meals/data/models/meal_detail_model.dart), [`json_parsing.dart`](lib/core/utils/json_parsing.dart) |
| `meals: null` handled without a crash | [`json_parsing.dart:28`](lib/core/utils/json_parsing.dart), covered in `test/core/utils/json_parsing_test.dart` and the search tests |
| Network errors mapped to messages | [`error_mapper.dart:10`](lib/core/error/error_mapper.dart) |
| Business logic separated from the UI | Cubits in each feature's `presentation/cubit`, use cases in `domain/usecases` |
| Open the video with `url_launcher` | [`link_launcher.dart:27`](lib/core/services/link_launcher.dart), button at [`meal_details_view.dart:139`](lib/features/meal_details/presentation/widgets/meal_details_view.dart) |
| Heart to save or remove | [`MealFavoriteHeart`](lib/features/favorites/presentation/widgets/meal_favorite_heart.dart), on every card and in the details header |
| Favourites survive a restart | [`favorites_local_data_source.dart:58`](lib/features/favorites/data/datasources/favorites_local_data_source.dart) (`SharedPreferences`), tested by closing and reopening the app in `favorites_flow_test.dart` |
| **Bonus:** Hero animation | [`meal_details_hero_image.dart:38`](lib/features/meal_details/presentation/widgets/meal_details_hero_image.dart) and the matching `Hero` on each card |
| **Bonus:** debounce in the search bar | [`debouncer.dart:6`](lib/core/utils/debouncer.dart), used at [`search_cubit.dart:33`](lib/features/search/presentation/cubit/search_cubit.dart) |

## Design

Taken from the Figma file *Food Recipe App (Community) Copy*, not the exam's link: colours,
the Poppins type scale, spacing and the notched bottom bar (reproduced from the exported path).
Where the design and the exam disagreed, the decisions are written down in
[docs/03-open-questions.md](docs/03-open-questions.md).

## What is placeholder

TheMealDB has no accounts, ratings, cook times or authors, but the design shows them. They are
generated from the meal id in one file, [`ui_placeholders.dart`](lib/core/utils/ui_placeholders.dart),
so a meal always shows the same values. Specifically: ratings, review counts, cook times, video
lengths, recipe authors, the Follow button, the Profile person and counts (except "Recipe", which is
the real saved-meal count), and the Notifications list. Follow and Edit profile do nothing.

## Known gaps

- **Not run on a device or emulator.** Everything was verified through `flutter analyze` and widget
  tests (real Poppins loaded, so overflow checks use true text widths).
- **Welcome photo is missing.** It could not be exported from Figma, so the screen shows a dark
  gradient. Put a photo at `assets/images/onboarding.jpg` and it appears with no code change.
- **Notifications was built without its Figma frame** (the design tool's call limit), so it follows
  the app's style rather than the design.
- **No native splash screen**, so a first launch can show a brief white frame before the dark
  welcome screen.
- The design's "Video" / "Recipe" tabs and "more" menus are left out where they would do nothing.

## Testing

566 offline tests (plus 5 opt-in live ones): models against real captured responses and hostile
all-null input, use cases, repositories, every Cubit, every screen in each state, layout at 320, 375
and 430 wide, and an audit of every screen at 130 % and 200 % system text size.

## Progress

- [x] Stage 0: foundation (theme, core, DI, router, custom notched nav bar)
- [x] Stage 1: meals domain and data layer
- [x] Stage 2: Home
- [x] Stage 3: category meals grid
- [x] Stage 4: meal details
- [x] Stage 5: favorites
- [x] Stage 6: search
- [x] Stage 7: onboarding, notifications, profile
- [x] Stage 8: polish, QA, README

## Documentation

| Doc | What it covers |
|---|---|
| [docs/00-requirements.md](docs/00-requirements.md) | The original assessment brief |
| [docs/01-system-design.md](docs/01-system-design.md) | Architecture, folder layout, domain model, state management |
| [docs/02-screens-and-design-map.md](docs/02-screens-and-design-map.md) | Figma frame to screen mapping |
| [docs/03-open-questions.md](docs/03-open-questions.md) | Design conflicts and the decisions taken |
| [docs/04-implementation-stages.md](docs/04-implementation-stages.md) | The staged build plan |
