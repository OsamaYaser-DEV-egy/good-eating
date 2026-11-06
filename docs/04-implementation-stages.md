# Implementation Stages

Nine stages. Each one ends with the app still running, `flutter analyze` clean, and `flutter test` green.
**I stop and ask you before starting each stage**, and I ask for the Figma node link for any stage
that draws a screen.

---

## Stage 0 — Foundation

*No screens yet. The skeleton everything else drops into.*

- `pubspec.yaml`: `flutter_bloc`, `dio`, `equatable`, `get_it`, `cached_network_image`, `url_launcher`,
  `shimmer`, `flutter_animate`, `shared_preferences`; dev deps `bloc_test`, `mocktail`.
- Strict `analysis_options.yaml` (system design §12).
- Full `lib/` folder skeleton.
- `core/theme`: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppTheme` — every token from
  the Figma `Styles` page.
- Poppins Regular + SemiBold bundled and registered.
- `core/error`: `Failure`, exceptions, `ErrorMapper`. `core/utils/result.dart`.
  `core/state/data_state.dart`. `core/utils/ui_placeholders.dart`.
- `core/network`: `DioFactory` (base url, 15 s timeouts, debug-only log interceptor) + `ApiClient`.
- `app/di/injector.dart`, `app/app.dart`, `app/router/*`, `bootstrap.dart`, rewritten `main.dart`.
- `features/shell`: `AppShellPage` + `ShellCubit` + the **custom 5-slot notched nav bar**
  (Home · Saved · [centre Search] · Notifications · Profile) with placeholder tab bodies.

**Figma needed:** `?node-id=128-14` (Styles) and `?node-id=139-3640` (Nav Bar).
**Done when:** the app launches to an empty shell, the notched nav bar animates between tabs, the
centre button routes to the Search tab, and `flutter analyze` is silent.

---

## Stage 1 — Meals domain + data layer

*Still no screens. Everything the UI will need, fully tested.*

- Entities: `MealCategory`, `MealSummary`, `Ingredient`, `MealDetail`.
- Models with `fromJson` honouring every rule in system design §4.1 — especially `meals: null` → `[]`
  and the 1..20 ingredient flattening.
- `MealRemoteDataSource` with the four endpoints.
- `MealRepository` interface + `MealRepositoryImpl` returning `Result<T>`, with a small in-memory
  cache for categories and per-category meal lists.
- Use cases: `GetCategories`, `GetMealsByCategory`, `GetMealDetails`, `SearchMeals`.
- DI registrations.
- **Tests:** `fromJson` against real captured responses *and* an all-null hostile fixture; repository
  tests for success, `DioException` → `NetworkFailure` / `TimeoutFailure` / `ServerFailure`, and
  malformed JSON → `ParsingFailure`.

**Figma needed:** none.
**Done when:** `flutter test` is green and a scratch run prints real categories and meals.

---

## Stage 2 — Home screen

- `CategoriesCubit`, `SelectedCategoryCubit`, `CategoryMealsCubit`, `HomeFeedCubit`.
- `HomePage` as a faithful copy of the design: heading, search field, **Trending now**,
  **Popular category** (the exam's category chips + cards), **Recent recipe**, **Popular creators**.
- Reusable cards: `MealTrendingCard`, `MealPopularCard`, `MealRecentCard`, `CreatorAvatar`, `CategoryChip`.
- `UiPlaceholders` supplies rating, review count, cook time, video length and creators.
- "See all" on Trending, Recent and the Popular category header routes to `CategoryMealsPage`
  (hidden until that page exists); tapping a chip selects it in place.
- Per-section shimmer skeletons, `AppErrorView` + **Try again**, `AppEmptyView`.
- Staggered entrance animations.

**Figma needed:** `?node-id=131-238`.
**Done when:** Home matches the frame side by side, all four sections load, and there is no overflow
at 320 / 375 / 430 widths.

---

## Stage 3 — Category meals grid  *(the exam's `GridView.builder`)*

- `CategoryMealsPage`: `ScreenHeader` (back arrow + category name), the chip row pinned at the top,
  **2-column `GridView.builder`** of `filter.php?c=<selected>`.
- The grid cell reuses `MealPopularCard` (made to fill its cell) rather than a separate card, so the
  grid and the Popular carousel cannot drift apart. The Hero tag is added in Stage 4.
- Shimmer grid, error + **Try again**, empty state.
- `AnimatedSwitcher` cross-fade when the category changes; staggered item entrance.

**Figma needed:** none beyond Stage 2's card styles.
**Done when:** chips and "See all" both land here, switching a chip refetches, airplane mode shows the
error view and Try again recovers.

---

## Stage 4 — Meal details screen

- `MealDetailsCubit` over `GetMealDetails`.
- Hero image continuing from the tapped card (per-place hero tags), back button, **heart in the header** (not yet responding; Stage 5 wires it).
- Name, rating + reviews, creator row with Follow, `strArea` and `strCategory` pills.
- Ingredients section — design's grey rows, real ingredient thumbnails, live count.
- Instructions section as numbered steps.
- **Watch on YouTube** and a play button on the photo, via `LinkLauncher` / `url_launcher`; both hidden when `strYoutube` is blank.
- Detail shimmer skeleton for the lower part, error + retry.
- Card taps on Home and the category grid now open this screen.
- Android: `INTERNET` added to the main manifest (release builds had none), and an `https` query for `url_launcher`.

**Figma needed:** `?node-id=131-561`.
**Done when:** tapping any meal anywhere animates in, every field renders, the YouTube button opens
the video, and long instructions scroll without overflow.

---

## Stage 5 — Favorites

- `FavoritesLocalDataSource` (`shared_preferences`) + `FavoritesRepository` + use cases.
- App-scoped `FavoritesCubit` provided above the shell.
- `FavoritesPage` with the design's saved-recipe cards, Video/Recipe tabs, swipe-to-dismiss + Undo,
  empty state.
- Heart state syncs live between Home, the grid, Search results, details, and this tab.

**Figma needed:** `?node-id=131-453`.
**Done when:** saving from any screen updates everywhere instantly and the list survives a full app
kill and relaunch.

---

## Stage 6 — Search

- `SearchCubit` with a **300 ms debounce** and in-flight request cancellation.
- `SearchPage`: real `TextField`, clear button, result list cards.
- Idle · loading · results · `meals: null` empty state · error + retry.
- Reached from the nav bar's centre button and from Home's search field.

**Figma needed:** `?node-id=139-3178` and `?node-id=131-482`.
**Done when:** typing "chick" fires exactly one request after the pause, "zzzz" shows the empty state
with no crash, and results open the details screen.

---

## Stage 7 — Onboarding, Notifications, Profile

- `OnboardingPage` from the design; first-run flag in local storage; native splash so there is no
  white flash on launch.
- `NotificationsPage` — tabs, Today / Yesterday groups, rows driven by `UiPlaceholders`.
- `ProfilePage` — header, stats (saved count is real from `FavoritesCubit`), recipe cards.

**Figma needed:** `?node-id=131-213`, `?node-id=139-248`, `?node-id=131-753`.
**Done when:** a fresh install shows onboarding once, and both remaining tabs render their design
instead of a placeholder.

---

## Stage 8 — Polish, QA, hand-in

- Animation pass: Hero timing, stagger curves, nav bar, heart bounce.
- Overflow audit at 320 / 375 / 430 widths and at large system text scale.
- Offline / slow-network pass on every screen.
- `flutter analyze` zero issues, `flutter test` green, `dart format` applied.
- `README.md`: how to run, architecture summary, screenshots, and a rubric-to-code map that points at
  the `GridView.builder`, the debounce, the Hero, and the persistence by file and line.

**Figma needed:** none.
**Done when:** a cold `flutter run` on a clean device walks the whole app with no visual or console errors.
