# Screens & Figma Map

Design file: **Food Recipe App (Community) — Copy**
`https://www.figma.com/design/jDQC8ZXFvkKzh0pdhXjAfU/Food-Recipe-App--Community---Copy-`
File key: `jDQC8ZXFvkKzh0pdhXjAfU` · Canvas width **375** · Pages: `Cover`, `Wireframe`, `Mockup`, `Styles`, `Components`

---

## 1. What the design actually contains

Top-level frames on the `Mockup` page (`0:1`):

| Node id | Frame name | Size | What it really is |
|---|---|---|---|
| `131:213` | Onboarding | 375×812 | Full-bleed food photo, "Let's Cooking", "Start cooking" button |
| `131:238` | Home | 375×1443 | Heading, search field, Trending, Popular category (chips + cards), Recent, Popular creators, nav bar |
| `131:453` | Discover | 375×1109 | **Actually "Saved recipes"** — Video/Recipe tabs + saved cards, bookmark tab active |
| `131:561` | Recipe detail | 375×1016 | Back + more, title, video thumb, rating, creator + Follow, Ingredients list |
| `139:248` | Create recipe | 375×883 | **Mislabelled — it is Notifications** (Today / Yesterday groups + tabs) |
| `131:753` | Profile page | 375×1255 | Profile header + recipe cards + nav bar |
| `131:653` | Create recipe | 375×977 | Recipe form — **not built**, TheMealDB is read-only |
| `228:1060` / `228:988` / `228:1226` | Home / Recipe detail / Onboarding | 375×812 | Clipped duplicates of the same screens |

Supporting nodes:

| Node id | What |
|---|---|
| `128:14` | `Styles` page — typography + the full colour ramps |
| `128:278` | `Components` page |
| `139:3640` | Nav Bar instance — white bar, notch, floating red centre button, 4 icons |
| `139:3178` | Search `Field` component used in the Home heading |
| `131:349` | Home "Popular category" chip row |
| `131:359` / `131:302` / `131:270` / `131:239` | Home sections: Trending / Popular / Recent / Popular Chef |
| `131:482` | Saved-recipes card list (the list card style) |

---

## 2. Exam screen → app screen mapping

| Exam screen (§5) | App screen | Design source |
|---|---|---|
| Home Screen — category chips | `HomePage` | `131:238` Home (full design) |
| Home Screen — 2-column meals grid | `CategoryMealsPage` ("See all") | new screen, built from the Home card style |
| Meal Details Screen | `MealDetailsPage` | `131:561` + an added instructions section |
| Search Screen | `SearchPage` | `139:3178` field + `131:482` list cards |
| Favorites Screen | `FavoritesPage` | `131:453` "Saved recipes" |
| — | `OnboardingPage` | `131:213` |
| — | `NotificationsPage` | `139:248` |
| — | `ProfilePage` | `131:753` |

Exam §5.1 is therefore split across two screens: the **category chips with the selected state live on
Home**, and the **2-column `GridView.builder`** lives on the Category meals screen, reachable from
every chip and every "See all" button. See `03-open-questions.md` Q1 for why and for the mitigation.

---

## 3. Resolved conflicts

| # | Conflict | Resolution |
|---|---|---|
| C1 | Exam wants a 2-column grid; design Home has only carousels | Home is a faithful copy; the grid is its own screen behind "See all" and the chips |
| C2 | Design shows rating, reviews, cook time, video length, creator, Follow — the API has none of it | Kept, filled from `core/utils/ui_placeholders.dart`, derived deterministically from `idMeal` |
| C3 | Design's detail screen has no instructions and no save control in the app bar | An instructions section is added below ingredients; a **heart** goes in the app bar |
| C3b | Design saves with a bookmark; exam says heart | **Heart everywhere**, in the design's bookmark container shape |
| C4 | Nav bar's centre `+` creates recipes, which the API cannot do; Search has no slot | All five slots kept; the centre button's action becomes **Search** |

---

## 4. Where Home's carousel data comes from

The design's Home shows four different meal collections. TheMealDB has no "trending" or "recent"
concept, so each carousel is backed by a real endpoint with a documented, deterministic rule:

| Section | Data |
|---|---|
| Trending now | `filter.php?c=<categories[0]>`, first 5 meals |
| Popular category | `filter.php?c=<selected chip>`, first 10 meals — this is the live, interactive one |
| Recent recipe | `filter.php?c=<categories[1]>`, first 5 meals |
| Popular creators | `UiPlaceholders.creator` pool + avatars exported from the design |

Trending and Recent share the category-meals cache, so Home makes at most three network calls on
first load and zero on tab re-entry.

---

## 5. Screen specs

### 5.1 Home — `HomePage` (`131:238`)
- Heading "Find best recipes for cooking" (`h4Bold`, Neutral/90), status-bar safe.
- Search field rendered as a tappable field that switches to Search (matches the design, which is a button here).
- **Trending now 🔥** + See all → horizontal 280×254 cards: image, play overlay, rating badge, heart, video length, title, creator row.
- **Popular category** → the exam's `ListView.builder` of `categories.php` chips with the selected state (filled `Primary/50`, white text) + horizontal 150×231 cards showing image, name, cook time, heart.
- **Recent recipe** + See all → horizontal 124×191 cards.
- **Popular creators** + See all → circular avatars with names.
- Every "See all" and every chip opens `CategoryMealsPage`.
- States: shimmer skeletons shaped like each carousel · `AppErrorView` with **Try again** · `AppEmptyView`.

### 5.2 Category meals — `CategoryMealsPage` *(the exam's grid)*
- App bar with the category name and a back button.
- The same category chip row pinned at the top, so switching categories refetches `filter.php` here too.
- **2-column `GridView.builder`**, card = rounded image + name + heart + Hero tag.
- Shimmer grid while loading, error + **Try again**, empty state.
- Staggered fade/slide entrance; `AnimatedSwitcher` cross-fade when the category changes.

### 5.3 Meal details — `MealDetailsPage` (`131:561`)
- Hero image continuing from whichever card was tapped; back button; **heart** in the app bar.
- Name (`h4Bold`), rating + review count, creator row with Follow button.
- `strArea` and `strCategory` as chips.
- **Ingredients** — the design's grey rounded rows: real ingredient thumbnail, name, measure, live count in the header.
- **Instructions** — numbered steps parsed from `strInstructions` (added; not in the design).
- **Watch on YouTube** primary button via `url_launcher`, hidden when `strYoutube` is blank.
- Shimmer detail skeleton; error + retry.

### 5.4 Search — `SearchPage` (`139:3178` + `131:482`)
- The design's field as a real `TextField`, autofocused, with a clear button.
- **300 ms debounce** before calling `search.php`; in-flight requests cancelled (exam bonus).
- Results as the saved-recipe list cards.
- `meals: null` → friendly empty state, never a crash (exam §5.3). Idle state before the first query; error + retry.

### 5.5 Favorites — `FavoritesPage` (`131:453`)
- Title "Saved recipes", Video/Recipe tabs kept as a visual filter over the same list.
- Saved meals as the design's list cards with a filled heart.
- Remove via the heart and via swipe-to-dismiss with an Undo snackbar; empty state when nothing is saved.
- Survives a full app kill and relaunch (exam §5.4).

### 5.6 Onboarding — `OnboardingPage` (`131:213`)
- Full-bleed image, "60k+ Premium recipes" pill, "Let's Cooking" headline, "Start cooking" button.
- Shown once; the first-run flag shares the favorites storage.

### 5.7 Notifications — `NotificationsPage` (`139:248`)
- Tabs, Today / Yesterday groups, notification rows.
- Content from `UiPlaceholders`, styled exactly as designed.

### 5.8 Profile — `ProfilePage` (`131:753`)
- Profile header, stats row, recipe cards.
- The saved-recipes count is real, read from `FavoritesCubit`; the rest is placeholder.
