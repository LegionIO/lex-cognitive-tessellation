# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      module Helpers
        class Mosaic
          include Constants

          attr_reader :id, :domain, :tiles, :created_at

          def initialize(domain:)
            @id         = SecureRandom.uuid
            @domain     = domain.to_sym
            @tiles      = []
            @created_at = Time.now.utc
          end

          def add_tile(tile)
            @tiles << tile
            auto_connect(tile)
            tile
          end

          def total_coverage
            return 0.0 if @tiles.empty?

            raw = @tiles.sum(&:effective_coverage) / @tiles.size
            raw.clamp(0.0, 1.0).round(10)
          end

          def average_fit
            return 0.0 if @tiles.empty?

            (@tiles.sum(&:fit_score) / @tiles.size).round(10)
          end

          def gap_count = @tiles.count(&:gapped?)
          def seamless_count = @tiles.count(&:seamless?)
          def isolated_count = @tiles.count(&:isolated?)
          def complete? = total_coverage >= FULL_COVERAGE_THRESHOLD

          def coherence
            return 0.0 if @tiles.empty?

            connected = @tiles.count(&:well_connected?)
            (connected.to_f / @tiles.size).round(10)
          end

          def uniformity
            return 1.0 if @tiles.size <= 1

            coverages = @tiles.map(&:coverage)
            mean = coverages.sum / coverages.size
            variance = coverages.sum { |c| (c - mean)**2 } / coverages.size
            (1.0 - Math.sqrt(variance)).clamp(0.0, 1.0).round(10)
          end

          def to_h
            {
              id:             @id,
              domain:         @domain,
              tile_count:     @tiles.size,
              total_coverage: total_coverage,
              average_fit:    average_fit,
              coherence:      coherence,
              uniformity:     uniformity,
              gaps:           gap_count,
              seamless:       seamless_count,
              complete:       complete?
            }
          end

          private

          def auto_connect(new_tile)
            same_domain = @tiles.select { |t| t.domain == new_tile.domain && t.id != new_tile.id }
            same_domain.last(2).each do |neighbor|
              new_tile.connect!(neighbor.id)
              neighbor.connect!(new_tile.id)
              compute_fit(new_tile, neighbor)
            end
          end

          def compute_fit(tile_a, tile_b)
            shape_match = tile_a.shape == tile_b.shape ? 0.2 : 0.0
            type_match  = tile_a.tile_type == tile_b.tile_type ? 0.1 : 0.0
            base_fit    = 0.5 + shape_match + type_match + (rand * 0.2)
            tile_a.adjust_fit!(base_fit)
          end
        end
      end
    end
  end
end
