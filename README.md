# Good Eating

A food recipe app built with **Flutter**, **Cubit** (`flutter_bloc`), **Dio** and
**Clean Architecture**, on top of the free [TheMealDB](https://www.themealdb.com/api.php) API.

> Work in progress, built stage by stage. See [docs/04-implementation-stages.md](docs/04-implementation-stages.md).

## Documentation

| Doc | What it covers |
|---|---|
| [docs/00-requirements.md](docs/00-requirements.md) | The original assessment brief |
| [docs/01-system-design.md](docs/01-system-design.md) | Architecture, folder layout, domain model, state management |
| [docs/02-screens-and-design-map.md](docs/02-screens-and-design-map.md) | Figma frame to screen mapping |
| [docs/03-open-questions.md](docs/03-open-questions.md) | Design conflicts and the decisions taken |
| [docs/04-implementation-stages.md](docs/04-implementation-stages.md) | The staged build plan |

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

## Stack

| Concern | Choice |
|---|---|
| State management | `flutter_bloc` (Cubit only) |
| Networking | `dio` |
| Dependency injection | `get_it` |
| Images | `cached_network_image`, `flutter_svg` |
| Loading states | `shimmer` |
| Animation | `flutter_animate` |
| Local storage | `shared_preferences` |
| Typeface | Poppins (bundled) |

## Progress

- [x] **Stage 0**: foundation (theme, core, DI, router, custom notched nav bar)
- [x] **Stage 1**: meals domain and data layer
- [x] **Stage 2**: Home
- [x] **Stage 3**: category meals grid
- [x] **Stage 4**: meal details
- [x] **Stage 5**: favorites
- [ ] Stage 6: search
- [ ] Stage 7: onboarding, notifications, profile
- [ ] Stage 8: polish and QA
