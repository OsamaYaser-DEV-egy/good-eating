# Good Eating — System Design

> Flutter app for browsing world recipes on top of **TheMealDB** public API.
> Stack: **Flutter + Cubit (flutter_bloc) + Dio + Clean Architecture**.

---

## 1. Goals & constraints

| Constraint | Source | Decision |
|---|---|---|
| State management | user | `flutter_bloc` (Cubit only, no Bloc events) |
| Networking | user | `dio` + a thin typed client wrapper |
| Architecture | user | Clean Architecture, feature-first, 3 layers |
| API | exam §3 | TheMealDB v1 public key `1`, no auth, GET only |
| Screens | exam §5 | Home, Meal Details, Search, Favorites |
| Local storage | exam §5.4 | one of SharedPreferences / Sqflite / Hive |
| Design | user | Figma `Food Recipe App (Community) — Copy` (not the PDF's link) |
| Bonus | exam §6 | Hero animation + search debounce + persistent favorites |

---

## 2. Architecture

### 2.1 Layer rules

```
presentation  ──depends on──▶  domain  ◀──depends on──  data
   (UI, Cubit)                (pure Dart)             (Dio, storage)
```

1. **domain** has zero imports from `flutter`, `dio`, or `data`. Entities, repository *interfaces*, and use cases only.
2. **data** implements the domain interfaces. It owns the DTOs (`*Model`) and is the only layer that knows JSON keys like `strMealThumb`.
3. **presentation** talks to use cases only — never to a repository, a data source, or `Dio` directly.
4. Dependencies are wired once in `app/di/injector.dart` (`get_it`), so no layer constructs its own collaborators.

### 2.2 Call flow for one request

```
HomePage
  └─ context.read<CategoryMealsCubit>().load("Beef")
       └─ GetMealsByCategory(category)            ← domain use case
            └─ MealRepository.mealsByCategory()   ← domain interface
                 └─ MealRepositoryImpl            ← data
                      └─ MealRemoteDataSource.filterByCategory()
                           └─ ApiClient.get(filter.php, {c: Beef})
                                └─ Dio
                      ◀─ List<MealSummaryModel>   (fromJson)
                 ◀─ Result<List<MealSummary>>     (Success | Failed)
  ◀─ DataState<List<MealSummary>>                 emitted by the Cubit
```

Errors never cross a layer as raw exceptions. `data` catches `DioException` / `FormatException`,
maps them to a `Failure`, and returns `Failed(failure)`. The Cubit emits `DataFailure(failure)`
and the UI renders `AppErrorView(failure.message, onRetry: ...)`.

---

## 3. Folder structure

```
lib/
├─ main.dart                       # runApp(bootstrap)
├─ bootstrap.dart                  # binding init, DI init, guarded error zone
├─ app/
│  ├─ app.dart                     # MaterialApp + theme + onGenerateRoute
│  ├─ di/injector.dart             # get_it registrations (single source of wiring)
│  └─ router/
│     ├─ app_routes.dart           # route name constants
│     ├─ app_router.dart           # onGenerateRoute + typed arguments
│     └─ page_transitions.dart     # fade-through route builders
│
├─ core/                           # knows nothing about any feature
│  ├─ constants/
│  │  ├─ api_constants.dart        # base url + endpoint paths + query keys
│  │  ├─ app_assets.dart           # asset path constants
│  │  └─ app_durations.dart        # animation + debounce durations
│  ├─ error/
│  │  ├─ failure.dart              # sealed Failure hierarchy
│  │  ├─ exceptions.dart           # data-layer exceptions
│  │  └─ error_mapper.dart         # DioException/Object -> Failure
│  ├─ network/
│  │  ├─ dio_factory.dart          # configured Dio (timeouts, interceptors)
│  │  └─ api_client.dart           # get() returning decoded JSON or throwing
│  ├─ state/
│  │  └─ data_state.dart           # sealed DataState: Initial/Loading/Success/Failure
│  ├─ usecase/
│  │  └─ use_case.dart             # abstract UseCase<Out, In>, NoParams
│  ├─ utils/
│  │  ├─ result.dart               # sealed Result: Success | Failed
│  │  ├─ debouncer.dart            # used by search
│  │  ├─ ui_placeholders.dart      # rating/time/creator the API does not return (see Q2)
│  │  └─ extensions/               # BuildContext, String, num extensions
│  ├─ theme/
│  │  ├─ app_colors.dart           # Neutral/Primary/Secondary/Rating/Error/Success ramps
│  │  ├─ app_text_styles.dart      # Poppins h4..tiny, bold/regular
│  │  ├─ app_spacing.dart          # 4/8/12/16/20/24 scale, screen padding 20
│  │  ├─ app_radii.dart            # 8/12/16/20/full
│  │  └─ app_theme.dart            # ThemeData assembled from the above
│  └─ widgets/
│     ├─ app_network_image.dart    # CachedNetworkImage + shimmer + error fallback
│     ├─ app_shimmer.dart          # skeleton box primitives
│     ├─ app_error_view.dart       # message + "Try again" button
│     ├─ app_empty_view.dart       # illustration + message
│     ├─ app_bottom_nav_bar.dart   # custom notched nav bar (CustomPainter)
│     ├─ primary_button.dart
│     ├─ section_header.dart       # "Title ... See all →"
│     └─ favorite_heart_button.dart # animated heart save toggle
│
└─ features/
   ├─ meals/                       # SHARED meal domain + data, used by 4 UI features
   │  ├─ domain/
   │  │  ├─ entities/              # meal_category, meal_summary, meal_detail, ingredient
   │  │  ├─ repositories/meal_repository.dart
   │  │  └─ usecases/              # get_categories, get_meals_by_category,
   │  │                            # get_meal_details, search_meals
   │  ├─ data/
   │  │  ├─ models/                # meal_category_model, meal_summary_model, meal_detail_model
   │  │  ├─ datasources/meal_remote_data_source.dart
   │  │  └─ repositories/meal_repository_impl.dart
   │  └─ presentation/widgets/     # cards reused across home / grid / search / favorites
   │     ├─ meal_grid_card.dart
   │     ├─ meal_list_card.dart
   │     ├─ meal_trending_card.dart
   │     ├─ meal_popular_card.dart
   │     ├─ meal_recent_card.dart
   │     └─ category_chip.dart
   │
   ├─ favorites/
   │  ├─ domain/                   # favorites_repository + usecases
   │  ├─ data/                     # favorite_meal_model, local data source, repository impl
   │  └─ presentation/             # cubit, pages, widgets
   │
   ├─ home/presentation/           # cubit, pages, widgets
   ├─ category_meals/presentation/ # the exam's 2-column GridView screen ("See all")
   ├─ search/presentation/
   ├─ meal_details/presentation/
   ├─ onboarding/presentation/
   ├─ notifications/presentation/  # design-accurate, placeholder-driven
   ├─ profile/presentation/        # design-accurate, real saved-count
   └─ shell/presentation/          # bottom-nav scaffold (IndexedStack)
```

**Why `features/meals` is shared:** Home, Search, Favorites and Details all operate on the same
`MealSummary` / `MealDetail`. Duplicating the model per feature would break single-source-of-truth
and let `fromJson` drift. `meals` owns the domain; the other features are presentation shells over it.

---

## 4. Domain model

```dart
// MealCategory — from categories.php
final class MealCategory extends Equatable {
  final String id, name, thumbUrl, description;
}

// MealSummary — from filter.php / search.php list items
final class MealSummary extends Equatable {
  final String id, name, thumbUrl;
}

// Ingredient — a flattened strIngredientN / strMeasureN pair
final class Ingredient extends Equatable {
  final String name;      // strIngredientN
  final String measure;   // strMeasureN, may be empty
  String get thumbUrl;    // themealdb ingredient image CDN
}

// MealDetail — from lookup.php / search.php full object
final class MealDetail extends Equatable {
  final String id, name, category, area, instructions, thumbUrl;
  final String? youtubeUrl, sourceUrl;
  final List<String> tags;
  final List<Ingredient> ingredients;   // only non-empty pairs, 1..20
  MealSummary toSummary();              // used when favoriting from the details page
  List<String> get instructionSteps;    // instructions split into readable steps
}
```

### 4.1 JSON mapping rules — the fragile part of TheMealDB

| Rule | Handling |
|---|---|
| `meals` comes back as `null` when nothing matches | `MealsResponse.fromJson` returns an empty list and the repository returns `Success([])`. **Never** a null-check crash — exam §5.3 calls this out by name. |
| 20 flat `strIngredientN` / `strMeasureN` fields | Loop `1..20`; keep a pair only when `strIngredientN` is non-null **and** non-blank after trim. |
| Values arrive as `""`, `" "`, or `null` interchangeably | A single `String?.nullIfBlank` extension, used by every model. |
| Ids look numeric but are strings | All ids stay `String`; never `int.parse`. |
| `strTags` is `"Pasta,Curry"` or null | Split on comma, trim, drop blanks. |
| Unknown or extra keys | Ignored — models read keys explicitly, never iterate `Map.values`. `filter.php` now also returns `strArea` / `strCountry`; they are simply not read there. |
| `strArea` is null on newer recipes, with `strCountry` filled instead | `area` falls back to `strCountry`, so the origin is never blank when the API knows it. |
| A list entry is missing its id or name | The entry is dropped, not the whole list: `parseJsonList` skips anything that throws `ParsingException`. A detail lookup that ends up with no valid entry becomes `NotFoundFailure`. |
| Ingredient image URLs contain spaces | `ApiConstants.ingredientImageUrl` percent-encodes the name; an unencoded `soy sauce` fails to load. |

Every model gets a `fromJson` unit test with a real captured response plus a hostile fixture where
every field is null or blank.

---

## 5. Error handling

```dart
sealed class Failure {
  final String message;   // user-facing, English
  final Object? cause;    // dev-only, logged, never shown
}

final class NetworkFailure  extends Failure {}  // no connection / DNS
final class TimeoutFailure  extends Failure {}  // connect / receive timeout
final class ServerFailure   extends Failure {}  // 5xx, carries statusCode
final class NotFoundFailure extends Failure {}  // 404
final class ParsingFailure  extends Failure {}  // bad or unexpected JSON
final class CacheFailure    extends Failure {}  // local storage read/write
final class UnknownFailure  extends Failure {}
```

`ErrorMapper.fromDio(DioException)` is the single translation point. Nothing else builds a
`Failure` out of a `DioException`.

`Result<T>` is a sealed type (`Success<T>` / `Failed<T>`) rather than `dartz.Either`, so there is no
extra dependency and pattern matching reads naturally:

```dart
switch (await getCategories()) {
  case Success(:final value):   emit(DataSuccess(value));
  case Failed(:final failure):  emit(DataFailure(failure));
}
```

---

## 6. State management (Cubit)

A generic state covers everything shaped like "load one thing":

```dart
sealed class DataState<T> {}
final class DataInitial<T> extends DataState<T> {}
final class DataLoading<T> extends DataState<T> {}
final class DataSuccess<T> extends DataState<T> { final T data; }
final class DataFailure<T> extends DataState<T> { final Failure failure; }
```

| Cubit | State | Owns |
|---|---|---|
| `CategoriesCubit` | `DataState<List<MealCategory>>` | categories.php, cached in memory after first success |
| `SelectedCategoryCubit` | `String?` | the active category name, drives the chip highlight |
| `CategoryMealsCubit` | `DataState<List<MealSummary>>` | filter.php for the selected category |
| `HomeFeedCubit` | `DataState<HomeFeed>` | the Trending and Recent carousels, off the shared category cache |
| `MealDetailsCubit` | `DataState<MealDetail>` | lookup.php for one id |
| `SearchCubit` | sealed `SearchState`: Idle / Loading / Results / Empty / Error | debounced search.php |
| `FavoritesCubit` | `DataState<List<MealSummary>>` | local storage, exposes `toggle(meal)` and `isFavorite(id)` |
| `ShellCubit` | `ShellTab` enum | the selected shell tab (home, saved, search, notifications, profile) |
| `OnboardingCubit` | `bool` | first-run flag |

Rules:

- One Cubit, one responsibility. Category **selection** is separate from category **meals**, so tapping
  a chip highlights instantly while the grid runs its own loading state.
- `FavoritesCubit` is a single app-scoped instance (a `lazySingleton` provided above the shell), so the
  heart on the details page, the heart on every card, the favorites tab, and the Profile saved-count
  all read one list — no manual refresh, no duplicated storage reads.
- Cubits never touch `BuildContext` and never import `material.dart`.

---

## 7. Navigation

- `MaterialApp.onGenerateRoute` → `AppRouter.generate`. No routing package needed.
- The root route is a **shell**: `AppShellPage` holds the custom bottom nav bar and an `IndexedStack`
  of the five tab pages (Home · Saved · Search · Notifications · Profile), so each tab keeps its
  scroll position and loaded state across switches.
- `CategoryMealsPage` and `MealDetailsPage` are pushed **above** the shell (full screen, nav bar hidden), carrying a typed
  `MealDetailsArgs(id, heroTag, previewThumbUrl, previewName)` so the Hero image and the title render
  immediately while `lookup.php` is still in flight.
- A custom fade-through transition for pushes; Hero handles the image.

---

## 8. Theming — tokens read from the Figma `Styles` page

Font family: **Poppins** (Regular 400 / SemiBold 600).

**Neutral** — `100 #181818 · 90 #303030 · 80 #484848 · 70 #606060 · 60 #797979 · 50 #919191 · 40 #A9A9A9 · 30 #C1C1C1 · 20 #D9D9D9 · 10 #F1F1F1 · 0 #FFFFFF`

**Primary (brand red)** — `50 #E23E3E · 30 #EE8B8B · 10 #F9D8D8`

**Secondary (amber)** — `100 #804E00 · 90 #995E00 · 80 #B36D00 · 70 #CC7D00 · 60 #E68C00 · 50 #FF9C00 · 40 #FFA61A · 30 #FFBA4D · 20 #FFCE80 · 10 #FFE1B3 · 0 #FFF5E6`

**Rating** `#FFB661` · **Error** `100 #EE1133 · 10 #FDE7EB` · **Success** `100 #31B057 · 10 #EAF7EE`
· **Dark grey** `#808A96` (secondary label text)

Type scale, straight from the Figma variables:

| Token | Size / weight / line-height |
|---|---|
| `h4Bold` | 24 / 600 / 1.2 |
| `h5Bold` | 20 / 600 / 1.4 |
| `paragraphBold` | 16 / 600 / 1.4 |
| `labelBold` / `labelRegular` | 14 / 600 · 400 / 1.4 |
| `smallBold` / `smallRegular` | 12 / 600 · 400 |
| `tinyRegular` | 10 / 400 |

Layout constants taken from the design: screen horizontal padding **20**, section gap **24**,
card radius **16**, chip radius **full**, design canvas width **375**. All sizing is relative —
no hard-coded screen widths anywhere.

---

## 9. Custom bottom navigation bar

The Figma nav bar is a white 375×120 bar with a **notch cut out of the top edge** and a floating red
circular action button sitting in that notch; the active icon turns `Primary/50`.

All five design slots are kept — `Home · Saved · [ centre ] · Notifications · Profile` — and the
centre button's action becomes **Search**, since TheMealDB cannot create recipes.

Built by hand (no package) so it matches exactly:

- `AppBottomNavBar` uses a `CustomPainter` that reproduces the exact bezier path exported from Figma (notch 109.75 wide, 41 deep, centred) plus its `#6C6C6C` 8 % drop shadow. The bar stretches to any width while the notch keeps its size.
- Items animate colour and a 1.1× scale pop on selection (`AnimatedScale` + `AnimatedDefaultTextStyle`).
- The centre action button is a `Material` circle with an `InkWell` ripple and a white search glyph, since its action is Search.
- Safe-area aware; the bar never overlaps the home indicator.

---

## 10. Animation plan (exam bonus §6)

| Where | Animation |
|---|---|
| Card → details | **Hero** on the meal image (the bonus requirement) |
| Grid / list appearance | staggered fade + 12px slide-up via `flutter_animate` |
| Category change | `AnimatedSwitcher` cross-fade on the grid |
| Favorite toggle | scale-bounce + colour tween on the heart |
| Loading | `shimmer` skeletons shaped like the real cards, not a bare spinner |
| Page push | fade-through transition |
| Nav bar | animated icon colour, scale, and action-button rotation |

---

## 11. Packages

| Package | Why |
|---|---|
| `flutter_bloc` | Cubit (required by you) |
| `dio` | HTTP (required by you) |
| `equatable` | value equality for entities and states |
| `get_it` | DI container, manual registration, no codegen |
| `cached_network_image` | image caching + placeholders (exam §6) |
| `url_launcher` | open the YouTube recipe (exam §5.2) |
| `shimmer` | skeleton loading (exam §5.1) |
| `flutter_animate` | declarative staggered / entrance animations |
| `shared_preferences` **or** `hive_ce` | favorites persistence — see open question Q6 |
| `flutter_svg` | only if we export the Figma icon set as SVG |
| `flutter_lints` + extra rules | enforced in `analysis_options.yaml` |

No routing package, no code generation, no `dartz` — all avoidable complexity.

---

## 12. Code-quality rules enforced in this repo

1. `analysis_options.yaml` adds `prefer_const_constructors`, `always_declare_return_types`,
   `require_trailing_commas`, `avoid_print`, `prefer_single_quotes`, `unawaited_futures`,
   `use_super_parameters`, and makes unused imports an **error**.
2. No magic numbers and no raw hex in widgets — only `AppColors`, `AppSpacing`, `AppRadii`, `AppTextStyles`.
3. No `Widget _buildX()` helper methods; every visual block is its own `const`-constructible widget class.
4. A `build` method stays under roughly 40 lines.
5. No `!` applied to anything that came out of JSON.
6. `const` everywhere it is legal.
7. Every `ListView` / `GridView` / `Column` is checked for overflow at 320 / 375 / 430 logical widths —
   exam §6 penalises Pixel Overflow explicitly.
8. Unit tests for every `fromJson`, every use case, and the favorites repository; `bloc_test` Cubit
   tests for the loading→success and loading→failure paths.

---

## 13. Traceability — exam rubric to implementation

| Rubric item (exam §6) | Pts | Satisfied by |
|---|---|---|
| UI & layout fidelity, no overflow | 25 | `core/theme` tokens from Figma, per-stage design review, rule §12.7 |
| API + models, null safety, error handling | 25 | `features/meals/data`, `core/error`, §4.1 mapping rules |
| Category chips with selected state | (part of 25) | `features/home` chip row over `categories.php` |
| 2-column `GridView.builder` | (part of 25) | `features/category_meals` — reached from every chip and "See all" |
| State management, loading/success/error, category switching | 25 | §6 Cubits + `DataState<T>` |
| Clean architecture, folder layout, small widgets | 15 | §2–§3, rule §12.3 |
| Local storage surviving restart | 10 | `features/favorites/data` |
| Bonus: Hero animation + search debounce | +10 | §10, `core/utils/debouncer.dart` |
