# Aura Fashion Mobile

Flutter client for the Aura Fashion e-commerce app, built with clean architecture and Bloc/Cubit. Talks to the [aura-fashion-backend](../aura-fashion-backend) Go API.

## Architecture

```
lib/
  core/
    constants/        API endpoints, storage keys
    di/                get_it service locator (injection_container.dart)
    error/             Failure (domain) / Exception (data) types
    network/           Dio client (auth interceptor), connectivity check
    theme/             App-wide ThemeData
    usecases/          Base UseCase<Result, Params> contract
  features/
    auth/
      data/            models, remote/local data sources, repository impl
      domain/          entities, repository interface, use cases
      presentation/    AuthCubit + AuthState, login/register pages
    products/
      data/ domain/ presentation/   same layering, product catalog
main.dart              DI bootstrap, MultiBlocProvider, auth-gated root
```

Dependency rule: `presentation` and `data` depend on `domain`; `domain` depends on nothing feature-specific. Each feature's repository interface lives in `domain`, its implementation in `data` — swapping Dio for something else only touches the `data` layer.

New features (cart, orders, categories, ...) should follow the same three-layer shape as `auth`/`products`.

## State management

[flutter_bloc](https://pub.dev/packages/flutter_bloc) — Cubits per feature (`AuthCubit`, `ProductCubit`), each with an `Equatable` state class using a `status` enum (`initial` / `loading` / `success` / `failure`). Use cases return `Either<Failure, T>` ([dartz](https://pub.dev/packages/dartz)) so cubits handle success/failure without try/catch.

## Key dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` / `equatable` | State management |
| `dio` | HTTP client, with a JWT-attaching interceptor |
| `get_it` | Service locator / DI |
| `dartz` | `Either<Failure, T>` functional error handling |
| `shared_preferences` | Caches the logged-in user for instant app resume |
| `flutter_secure_storage` | Stores the JWT (not in plain prefs) |
| `connectivity_plus` | Network-availability check before API calls |
| `cached_network_image` | Product image loading/caching |

Dev: `bloc_test`, `mocktail` for testing; `build_runner`/`json_serializable` available for future model codegen.

## Setup

1. Make sure the [backend](../aura-fashion-backend) is running (default `http://localhost:8080`).
2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run against the backend. The Android emulator can't reach `localhost` directly, so the default `API_BASE_URL` points at `10.0.2.2` (the emulator's alias for the host machine):

   ```bash
   flutter run
   ```

   To point at a different backend (physical device, staging, etc.), override at build/run time:

   ```bash
   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/api/v1
   ```

## Testing

```bash
flutter analyze
flutter test
```
