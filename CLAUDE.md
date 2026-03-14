# lex-cognitive-tessellation

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-tessellation`
- **Version**: 0.1.0
- **Namespace**: `Legion::Extensions::CognitiveTessellation`

## Purpose

Models knowledge coverage as a tessellation — a pattern of tiles fitting together without gaps or excessive overlap. Each tile represents a unit of cognitive content (knowledge, skill, pattern, belief, etc.) in a domain. Tiles expand or shrink in coverage, connect to adjacent tiles, and auto-organize into per-domain mosaics. The model surfaces gaps (under-covered tiles), seamless fits (well-integrated tiles), and overall coherence.

## Gem Info

- **Gemspec**: `lex-cognitive-tessellation.gemspec`
- **Require**: `lex-cognitive-tessellation`
- **Ruby**: >= 3.4
- **License**: MIT
- **Homepage**: https://github.com/LegionIO/lex-cognitive-tessellation

## File Structure

```
lib/legion/extensions/cognitive_tessellation/
  version.rb
  helpers/
    constants.rb              # Shapes, domains, tile types, coverage/fit/density label tables
    tile.rb                   # Tile class — one cognitive knowledge unit
    mosaic.rb                 # Mosaic class — per-domain tile collection
    tessellation_engine.rb    # TessellationEngine — registry and aggregate metrics
  runners/
    cognitive_tessellation.rb  # Runner module — public API
  client.rb
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_TILES` | 500 | Hard cap; lowest effective-coverage tiles pruned when exceeded |
| `MAX_MOSAICS` | 50 | Max per-domain mosaics (not enforced in engine) |
| `FULL_COVERAGE_THRESHOLD` | 0.95 | Coverage >= this = `full_coverage?` true |
| `GAP_THRESHOLD` | 0.3 | Fit score < this = `gapped?` true |
| `OVERLAP_THRESHOLD` | 0.7 | Fit + many adjacents triggers `overlapping?` |
| `FIT_TOLERANCE` | 0.05 | Reference tolerance (defined, not used) |
| `COVERAGE_GROWTH` | 0.08 | Coverage increase per `expand!` |
| `COVERAGE_DECAY` | 0.02 | Coverage decrease per `shrink!` |
| `OVERLAP_PENALTY` | 0.05 | Per-adjacent penalty when `overlapping?` |

`TILE_SHAPES`: `[:triangular, :square, :hexagonal, :pentagonal, :irregular, :fractal, :amorphous, :crystalline]`

`DOMAINS`: `[:cognitive, :emotional, :procedural, :semantic, :episodic, :social, :creative, :analytical]`

`TILE_TYPES`: `[:knowledge, :skill, :pattern, :belief, :heuristic, :schema, :model, :framework]`

Coverage labels: `0.9+` = `:complete`, `0.7..0.9` = `:substantial`, `0.5..0.7` = `:partial`, `0.3..0.5` = `:sparse`, `<0.3` = `:fragmented`

Fit labels: `0.8+` = `:seamless`, `0.6..0.8` = `:snug`, `0.4..0.6` = `:loose`, `0.2..0.4` = `:gapped`, `<0.2` = `:disjointed`

## Key Classes

### `Helpers::Tile`

One cognitive knowledge unit.

- `expand!(amount)` — increases coverage by amount (default `COVERAGE_GROWTH`)
- `shrink!(amount)` — decreases coverage by amount (default `COVERAGE_DECAY`)
- `adjust_fit!(new_fit)` — sets fit score
- `connect!(other_id)` — adds to `adjacent_ids` (no duplicates)
- `full_coverage?` — coverage >= 0.95; `gapped?` — fit_score < 0.3; `seamless?` — fit_score >= 0.8
- `overlapping?` — fit_score > 0.7 AND adjacent_ids.size > 3
- `isolated?` — no adjacent tiles; `well_connected?` — 3+ adjacent tiles
- `effective_coverage` — coverage minus overlap penalties

### `Helpers::Mosaic`

A per-domain collection of tiles.

- `add_tile(tile)` — appends and auto-connects to last 2 tiles in same domain via `compute_fit`
- `total_coverage` — mean effective_coverage across tiles
- `coherence` — ratio of well-connected tiles (adjacency >= 3)
- `uniformity` — `1 - sqrt(variance_of_coverages)`; high = tiles are evenly covered
- `complete?` — total_coverage >= `FULL_COVERAGE_THRESHOLD`
- `auto_connect` computes fit: `0.5 + shape_match(0.2 if same) + type_match(0.1 if same) + rand(0..0.2)`

### `Helpers::TessellationEngine`

Registry for all tiles and mosaics.

- `create_tile(tile_type:, shape:, domain:, coverage:, fit_score:)` — auto-creates mosaic for domain; prunes lowest-coverage if over `MAX_TILES`
- `expand_tile(tile_id:, amount:)` — delegates to tile
- `shrink_all!` — shrinks every tile by `COVERAGE_DECAY`
- `connect_tiles(tile_a_id:, tile_b_id:)` — bidirectional adjacency
- `gapped_tiles` / `seamless_tiles` / `isolated_tiles` / `full_coverage_tiles` — filtered tile lists
- `overall_coverage` / `overall_fit` / `overall_coherence` — aggregate scores
- `gap_density` — ratio of gapped tiles
- `tessellation_report` — full report with all counts and labels

## Runners

Module: `Legion::Extensions::CognitiveTessellation::Runners::CognitiveTessellation`

| Runner | Key Args | Returns |
|---|---|---|
| `create_tile` | `tile_type:`, `shape:`, `domain:`, `coverage:`, `fit_score:` | `{ success:, tile: }` |
| `expand_tile` | `tile_id:`, `amount:` | `{ success:, tile: }` or `{ success: false, error: }` |
| `connect_tiles` | `tile_a_id:`, `tile_b_id:` | `{ success:, connected:, tile_a:, tile_b: }` or error |
| `shrink_all` | — | `{ success: true }` |
| `list_gaps` | — | `{ success:, count:, tiles: }` |
| `tessellation_status` | — | `{ success:, total_tiles:, overall_coverage:, gap_density:, mosaics:, ... }` |

Note: the runner uses `@default_engine` directly (not `engine || @default_engine` for all runners — `create_tile` uses the pattern but some others don't initialize it lazily).

## Integration Points

- No actors defined; `shrink_all` should be called periodically as a decay tick
- `list_gaps` identifies knowledge domains needing expansion — can drive learning prioritization
- Mosaics are auto-created per domain when the first tile for a domain is created
- All state is in-memory per `TessellationEngine` instance

## Development Notes

- The runner accesses `@default_engine` directly without the `||=` pattern in some methods — the engine must be initialized before those runners are called (via `create_tile` or another `||=` path)
- `compute_fit` in Mosaic includes `rand * 0.2` — fit scores have a random component introduced at tile connection time
- `overlapping?` requires BOTH high fit score AND more than 3 adjacents — fit score alone is not sufficient
- `auto_connect` connects new tiles to the last 2 tiles in the same domain only; tiles added to the same-domain mosaic but not via the engine are not connected
- `prune_tiles` removes the lowest-effective-coverage tiles when over `MAX_TILES`
