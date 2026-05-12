# Changelog

This project follows semantic versioning.

- `PATCH` for small fixes and safe incremental adjustments.
- `MINOR` for new features or additive behavior.
- `MAJOR` for breaking changes or structural resets.

## 0.1.0 - 2026-05-12

- Created the first modular BronzeBeard-focused addon core.
- Added defensive tooltip inspection, debug commands and semver tracking.
- Renamed the public addon identity to `RatingBuster-Bronzebeard`.

## 0.1.1 - 2026-05-12

- Split the new implementation into the recommended top-level modules such as `Core.lua`, `Compatibility.lua`, `Scanner.lua`, `Stats.lua`, `Ratings.lua`, `Compare.lua`, `Tooltip.lua`, `Debug.lua` and `ItemCache.lua`.
- Made scan enrichment idempotent so cached tooltip inspections do not duplicate summary values or breakdown lines.
- Added live player stat snapshot debug output backed by documented Ascension APIs when those globals exist at runtime.
- Documented that several derived conversions still require BronzeBeard-specific runtime validation because the documented APIs expose live unit totals rather than direct item deltas.

## 0.1.2 - 2026-05-12

- Stopped tooltip text parsing from double-counting stats on top of `GetItemStats`; tooltip parsing now fills gaps and highlights conflicts instead.
- Added debug visibility for unmapped raw stat keys, tooltip-parsed stats, slot fallback, visible tooltip item level and raw-versus-tooltip stat conflicts.
- Added compare fallback to use the visible tooltip equip slot when `GetItemInfo` does not expose one for the inspected item.
