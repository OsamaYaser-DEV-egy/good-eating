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
| Trending now | `filter.php?c=<categories[1]>`, first 5 meals |
| Popular category | `filter.php?c=<selected chip>`, first 10 meals — this is the live, interactive one |
| Recent recipe | `filter.php?c=<categories[2]>`, first 5 meals |
| Popular creators | `UiPlaceholders.allCreators` — the four portraits exported from the design |

Trending and Recent deliberately skip `categories[0]`, which the chips open on, so the same meals
are not shown twice on first load. The repository caches every response, so Home makes four network
calls on first load (categories plus three meal lists) and none when the tab is revisited.

---

## 5. Screen specs

### 5.1 Home — `HomePage` (`131:238`)
- Heading "Find best recipes for cooking" (`h4Bold`, Neutral/90), status-bar safe.
- Search field rendered as a tappable field that switches to Search (matches the design, which is a button here).
- **Trending now 🔥** + See all → horizontal 280×254 cards: image, play overlay, rating badge, heart, video length, title, creator row.
- **Popular category** → the exam's `ListView.builder` of `categories.php` chips with the selected state (filled `Primary/50`, white text) + horizontal 150×231 cards showing image, name, cook time, heart. **Tapping a chip selects it in place and swaps the cards**, exactly as the design's tabs do; the grid is reached through "See all".
- **Popular category header** also gets a "See all", which the design does not draw, so the grid can be opened for whichever chip is selected.
- **Recent recipe** + See all → horizontal 124×191 cards.
- **Popular creators** + See all → circular avatars with names.
- Every "See all" opens `CategoryMealsPage` (wired in Stage 3; the buttons are hidden until then, so Home never shows a control that does nothing). The creators row has no "See all" at all, because there is no creators page to open.
- States: shimmer skeletons shaped like each carousel · `AppErrorView` with **Try again** · `AppEmptyView`.

### 5.2 Category meals — `CategoryMealsPage` *(the exam's grid)*
The design has no frame for this screen, so it is assembled from existing pieces. Header: `ScreenHeader`, taken from the Recipe detail frame's header (`131:638`): 24 px back arrow 20 px in and 12 px down, then an h4 title (the category name).
- The same `CategoryTabs` as Home, pinned under the header, so switching category refetches `filter.php` here too. The grid owns its own `CategoryMealsCubit`, so choosing a chip here never changes Home's selection.
- **2-column `GridView.builder`** (`crossAxisCount: 2`, 16 px gaps, 20 px side padding). The cell is the Popular category card (`MealPopularCard`): round dish photo, name, cook time, heart. The card fills its cell, so it is 159.5 wide at 375 and 132 at 320. All meals in the category are shown, not the 10-card preview.
- Shimmer grid while loading, a full-area error with **Try again**, and a friendly empty state. The header and chips stay during all three, so the user can always pick another category.
- Only the first six cards stagger in; cards scrolled into view later appear at once. The meals area cross-fades when the category changes.
- Opened from "See all" on Trending (categories[1]), Recent (categories[2]) and the Popular category header (the selected chip). A pushed route above the shell, so there is no bottom bar.

### 5.3 Meal details — `MealDetailsPage` (`131:561`)
Built from the mockup frame, measured in Figma: `ScreenHeader` (back arrow, title), a 335×200 photo, rating row, creator row, then the sections.
- The photo is the landing spot of a **Hero** from whichever card was tapped. Tags are scoped per place (`trending`, `popular`, `recent`, `grid`), because the same meal often appears in two carousels at once and duplicate tags break navigation.
- The name and photo arrive with the tap, and the rating, creator and Follow button are derived from the id, so **everything above the ingredients shows immediately**; only the lower part shows a skeleton.
- Header right: a **heart** (exam §5.2), shown but not yet responding until Stage 5. The design's "more" icon is not drawn, because it has nothing behind it.
- `strArea` and `strCategory` appear as two pills between the creator row and the ingredients (the design has no slot for them; this placement avoids shifting the photo when they load). A blank one is left out.
- **Ingredients**: the design's 76 px grey rows with a 52 px white icon box. The icon is the real ingredient picture from TheMealDB's image CDN, not the design's emoji. The count reads "5 items" / "1 item".
- **Instructions**: numbered steps from `strInstructions` (added; the design stops at ingredients), with the same section style.
- **Video**: the play button on the photo and a **Watch on YouTube** button both open the link through `LinkLauncher` (`url_launcher`). Both are hidden when the recipe has no video, so the screen never promises one it cannot deliver. Only `http` and `https` links are opened, since the value comes from the API. If nothing can open it, a snackbar says so.
- The creator's location ("Bali, Indonesia") and the Follow button are placeholders (see `UiPlaceholders`); Follow has no account behind it, so it does nothing.
- Error: the header and photo stay and the lower part shows the failure with **Try again**.

### 5.4 Search — `SearchPage` (`139:3178` + `131:482`)
- The design's field as a real `TextField`, autofocused, with a clear button.
- **300 ms debounce** before calling `search.php`; in-flight requests cancelled (exam bonus).
- Results as the saved-recipe list cards.
- `meals: null` → friendly empty state, never a crash (exam §5.3). Idle state before the first query; error + retry.

### 5.5 Favorites — `FavoritesPage` (`131:453`)
- Title "Saved recipes" (the same `PageHeading` Home uses), then the saved meals newest first.
- Each card is the Trending card at full width (335 × 254, 16 apart). The Saved frame's card is the same layout as Trending's: photo with rating, heart, play button and length, then title and creator.
- **The design's "Video" and "Recipe" tabs are left out.** A saved meal is only an id, a name and a photo, so there is nothing to tell the two apart, and two tabs showing the same list would be controls that do nothing.
- Remove by tapping the heart or by swiping the card left. Either way a snackbar says "Removed from favorites" with **Undo**, which puts the meal back at its old position.
- A friendly empty state, a skeleton while the list is read, and an error with Try again if it cannot be.
- Hearts everywhere (Trending, Popular, the category grid, the details header, this list) read one shared `FavoritesCubit`, so they always agree.
- Survives a full app kill and relaunch (exam §5.4): the list is one JSON string in `SharedPreferences`. Unreadable stored data counts as "nothing saved", so a corrupt value can never stop the user saving again.
- If a save fails, the heart goes back to what is really stored and a snackbar says so, on whichever screen is open.

### 5.6 Onboarding — `OnboardingPage` (`131:213`)
- Full-bleed image, "60k+ Premium recipes" pill, "Let's Cooking" headline, "Start cooking" button.
- Shown once; the first-run flag shares the favorites storage.

### 5.7 Notifications — `NotificationsPage` (`139:248`)
- Tabs, Today / Yesterday groups, notification rows.
- Content from `UiPlaceholders`, styled exactly as designed.

### 5.8 Profile — `ProfilePage` (`131:753`)
- Profile header, stats row, recipe cards.
- The saved-recipes count is real, read from `FavoritesCubit`; the rest is placeholder.
