# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveTessellation
      module Helpers
        module Constants
          MAX_TILES = 500
          MAX_MOSAICS = 50

          DEFAULT_COVERAGE = 0.0
          FULL_COVERAGE_THRESHOLD = 0.95
          GAP_THRESHOLD = 0.3
          OVERLAP_THRESHOLD = 0.7
          FIT_TOLERANCE = 0.05

          COVERAGE_GROWTH = 0.08
          COVERAGE_DECAY = 0.02
          OVERLAP_PENALTY = 0.05

          TILE_SHAPES = %i[
            triangular square hexagonal pentagonal
            irregular fractal amorphous crystalline
          ].freeze

          DOMAINS = %i[
            cognitive emotional procedural semantic
            episodic social creative analytical
          ].freeze

          TILE_TYPES = %i[
            knowledge skill pattern belief
            heuristic schema model framework
          ].freeze

          COVERAGE_LABELS = {
            (0.9..)     => :complete,
            (0.7...0.9) => :substantial,
            (0.5...0.7) => :partial,
            (0.3...0.5) => :sparse,
            (..0.3)     => :fragmented
          }.freeze

          FIT_LABELS = {
            (0.8..)     => :seamless,
            (0.6...0.8) => :snug,
            (0.4...0.6) => :loose,
            (0.2...0.4) => :gapped,
            (..0.2)     => :disjointed
          }.freeze

          DENSITY_LABELS = {
            (0.8..)     => :saturated,
            (0.6...0.8) => :dense,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :thin,
            (..0.2)     => :vacant
          }.freeze

          def self.label_for(labels, value)
            labels.each { |range, label| return label if range.cover?(value) }
            :unknown
          end
        end
      end
    end
  end
end
