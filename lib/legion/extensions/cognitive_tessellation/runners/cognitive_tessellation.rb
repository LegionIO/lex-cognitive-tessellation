# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      module Runners
        module CognitiveTessellation
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_tile(tile_type:, shape:, domain:, coverage: nil, fit_score: nil, engine: nil, **)
            eng = engine || @default_engine
            tile = eng.create_tile(tile_type: tile_type, shape: shape, domain: domain,
                                   coverage: coverage, fit_score: fit_score)
            { success: true, tile: tile.to_h }
          end

          def expand_tile(tile_id:, amount: nil, engine: nil, **)
            eng = engine || @default_engine
            tile = eng.expand_tile(tile_id: tile_id, amount: amount || Helpers::Constants::COVERAGE_GROWTH)
            return { success: false, error: 'tile not found' } unless tile

            { success: true, tile: tile.to_h }
          end

          def connect_tiles(tile_a_id:, tile_b_id:, engine: nil, **)
            eng = engine || @default_engine
            result = eng.connect_tiles(tile_a_id: tile_a_id, tile_b_id: tile_b_id)
            return { success: false, error: 'one or both tiles not found' } unless result

            { success: true, **result }
          end

          def shrink_all(engine: nil, **)
            eng = engine || @default_engine
            eng.shrink_all!
            { success: true }
          end

          def list_gaps(engine: nil, **)
            eng = engine || @default_engine
            gaps = eng.gapped_tiles
            { success: true, count: gaps.size, tiles: gaps.map(&:to_h) }
          end

          def tessellation_status(engine: nil, **)
            eng = engine || @default_engine
            report = eng.tessellation_report
            { success: true, **report }
          end
        end
      end
    end
  end
end
