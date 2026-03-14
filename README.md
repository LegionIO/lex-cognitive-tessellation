# lex-cognitive-tessellation

A LegionIO cognitive architecture extension that models knowledge coverage as a tessellation. Tiles represent cognitive units (knowledge, skills, patterns, beliefs) that fit together across domains, growing through expansion and fading through decay.

## What It Does

Tracks **tiles** of eight types (`knowledge`, `skill`, `pattern`, `belief`, `heuristic`, `schema`, `model`, `framework`) across eight domains (`cognitive`, `emotional`, `procedural`, `semantic`, `episodic`, `social`, `creative`, `analytical`).

Each tile has coverage (how much of its domain it explains) and a fit score (how well it integrates with neighbors). Tiles auto-organize into per-domain mosaics when created. The system surfaces gaps, isolated tiles, and coherence across the knowledge landscape.

## Usage

```ruby
require 'lex-cognitive-tessellation'

client = Legion::Extensions::CognitiveTessellation::Client.new

# Create a knowledge tile
t1 = client.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :semantic, coverage: 0.4)
# => { success: true, tile: { id: "uuid...", coverage: 0.4, fit_score: 0.5, gapped: false, seamless: false, ... } }

t2 = client.create_tile(tile_type: :schema, shape: :hexagonal, domain: :semantic, coverage: 0.6)
t3 = client.create_tile(tile_type: :knowledge, shape: :square, domain: :procedural, coverage: 0.2)

# Expand a tile's coverage
client.expand_tile(tile_id: t1[:tile][:id], amount: 0.1)
# => { success: true, tile: { coverage: 0.5, ... } }

# Explicitly connect two tiles
client.connect_tiles(tile_a_id: t1[:tile][:id], tile_b_id: t2[:tile][:id])
# => { success: true, connected: true, tile_a: "uuid...", tile_b: "uuid..." }

# Find tiles with poor fit (gaps)
client.list_gaps
# => { success: true, count: 0, tiles: [] }

# Decay all tiles (periodic maintenance)
client.shrink_all
# => { success: true }

# Full tessellation report
client.tessellation_status
# => { success: true, total_tiles: 3, overall_coverage: 0.35, coverage_label: :sparse, gap_density: 0.0, mosaics: [...], ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
