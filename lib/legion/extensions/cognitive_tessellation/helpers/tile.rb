# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      module Helpers
        class Tile
          include Constants

          attr_reader :id, :tile_type, :shape, :domain, :coverage, :fit_score,
                      :adjacent_ids, :created_at

          def initialize(tile_type:, shape:, domain:, coverage: nil, fit_score: nil)
            @id          = SecureRandom.uuid
            @tile_type   = tile_type.to_sym
            @shape       = shape.to_sym
            @domain      = domain.to_sym
            @coverage    = (coverage || DEFAULT_COVERAGE).to_f.clamp(0.0, 1.0)
            @fit_score   = (fit_score || 0.5).to_f.clamp(0.0, 1.0)
            @adjacent_ids = []
            @created_at = Time.now.utc
          end

          def expand!(amount = COVERAGE_GROWTH)
            @coverage = (@coverage + amount).clamp(0.0, 1.0).round(10)
          end

          def shrink!(amount = COVERAGE_DECAY)
            @coverage = (@coverage - amount).clamp(0.0, 1.0).round(10)
          end

          def adjust_fit!(new_fit)
            @fit_score = new_fit.to_f.clamp(0.0, 1.0).round(10)
          end

          def connect!(other_id)
            @adjacent_ids << other_id unless @adjacent_ids.include?(other_id)
          end

          def full_coverage? = @coverage >= FULL_COVERAGE_THRESHOLD
          def gapped? = @fit_score < GAP_THRESHOLD
          def overlapping? = @fit_score > OVERLAP_THRESHOLD && @adjacent_ids.size > 3
          def isolated? = @adjacent_ids.empty?
          def well_connected? = @adjacent_ids.size >= 3
          def seamless? = @fit_score >= 0.8

          def effective_coverage
            penalty = overlapping? ? OVERLAP_PENALTY * @adjacent_ids.size : 0.0
            (@coverage - penalty).clamp(0.0, 1.0).round(10)
          end

          def to_h
            {
              id:                 @id,
              tile_type:          @tile_type,
              shape:              @shape,
              domain:             @domain,
              coverage:           @coverage.round(10),
              fit_score:          @fit_score.round(10),
              effective_coverage: effective_coverage,
              adjacent_count:     @adjacent_ids.size,
              full_coverage:      full_coverage?,
              gapped:             gapped?,
              seamless:           seamless?,
              created_at:         @created_at.iso8601
            }
          end
        end
      end
    end
  end
end
