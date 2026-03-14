# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      module Helpers
        class TessellationEngine
          include Constants

          def initialize
            @tiles   = {}
            @mosaics = {}
          end

          def create_tile(tile_type:, shape:, domain:, coverage: nil, fit_score: nil)
            tile = Tile.new(tile_type: tile_type, shape: shape, domain: domain,
                            coverage: coverage, fit_score: fit_score)
            @tiles[tile.id] = tile
            mosaic = find_or_create_mosaic(domain: domain)
            mosaic.add_tile(tile)
            prune_tiles
            tile
          end

          def expand_tile(tile_id:, amount: COVERAGE_GROWTH)
            tile = @tiles[tile_id]
            return nil unless tile

            tile.expand!(amount)
            tile
          end

          def shrink_all!
            @tiles.each_value { |t| t.shrink!(COVERAGE_DECAY) }
          end

          def connect_tiles(tile_a_id:, tile_b_id:)
            a = @tiles[tile_a_id]
            b = @tiles[tile_b_id]
            return nil unless a && b

            a.connect!(b.id)
            b.connect!(a.id)
            { connected: true, tile_a: a.id, tile_b: b.id }
          end

          def tiles_by_domain(domain:) = @tiles.values.select { |t| t.domain == domain.to_sym }
          def tiles_by_type(tile_type:) = @tiles.values.select { |t| t.tile_type == tile_type.to_sym }
          def tiles_by_shape(shape:) = @tiles.values.select { |t| t.shape == shape.to_sym }
          def gapped_tiles = @tiles.values.select(&:gapped?)
          def seamless_tiles = @tiles.values.select(&:seamless?)
          def isolated_tiles = @tiles.values.select(&:isolated?)
          def full_coverage_tiles = @tiles.values.select(&:full_coverage?)

          def overall_coverage
            return 0.0 if @mosaics.empty?

            (@mosaics.values.sum(&:total_coverage) / @mosaics.size).round(10)
          end

          def overall_fit
            return 0.0 if @tiles.empty?

            (@tiles.values.sum(&:fit_score) / @tiles.size).round(10)
          end

          def overall_coherence
            return 0.0 if @mosaics.empty?

            (@mosaics.values.sum(&:coherence) / @mosaics.size).round(10)
          end

          def domain_coverage
            @mosaics.transform_values(&:total_coverage)
          end

          def gap_density
            return 0.0 if @tiles.empty?

            (gapped_tiles.size.to_f / @tiles.size).round(10)
          end

          def most_covered(limit: 5)
            @tiles.values.sort_by { |t| -t.effective_coverage }.first(limit)
          end

          def least_covered(limit: 5)
            @tiles.values.sort_by(&:effective_coverage).first(limit)
          end

          def tessellation_report
            {
              total_tiles:      @tiles.size,
              total_mosaics:    @mosaics.size,
              overall_coverage: overall_coverage,
              coverage_label:   Constants.label_for(COVERAGE_LABELS, overall_coverage),
              overall_fit:      overall_fit,
              fit_label:        Constants.label_for(FIT_LABELS, overall_fit),
              overall_coherence: overall_coherence,
              gap_density:      gap_density,
              gapped_count:     gapped_tiles.size,
              seamless_count:   seamless_tiles.size,
              isolated_count:   isolated_tiles.size,
              domain_coverage:  domain_coverage,
              mosaics:          @mosaics.values.map(&:to_h)
            }
          end

          def to_h
            {
              total_tiles:   @tiles.size,
              total_mosaics: @mosaics.size,
              coverage:      overall_coverage,
              fit:           overall_fit,
              coherence:     overall_coherence
            }
          end

          private

          def find_or_create_mosaic(domain:)
            key = domain.to_sym
            @mosaics[key] ||= Mosaic.new(domain: key)
          end

          def prune_tiles
            return if @tiles.size <= MAX_TILES

            sorted = @tiles.values.sort_by(&:effective_coverage)
            to_remove = sorted.first(@tiles.size - MAX_TILES)
            to_remove.each { |t| @tiles.delete(t.id) }
          end
        end
      end
    end
  end
end
