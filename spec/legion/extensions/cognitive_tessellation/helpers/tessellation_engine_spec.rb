# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveTessellation::Helpers::TessellationEngine do
  subject(:engine) { described_class.new }

  describe '#create_tile' do
    it 'creates a tile and returns it' do
      tile = engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      expect(tile).to be_a(Legion::Extensions::CognitiveTessellation::Helpers::Tile)
    end

    it 'adds tile to a mosaic for its domain' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      report = engine.tessellation_report
      expect(report[:total_mosaics]).to eq(1)
    end

    it 'reuses existing mosaic for same domain' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      engine.create_tile(tile_type: :skill, shape: :square, domain: :cognitive)
      report = engine.tessellation_report
      expect(report[:total_mosaics]).to eq(1)
    end

    it 'creates separate mosaics for different domains' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      engine.create_tile(tile_type: :skill, shape: :square, domain: :emotional)
      report = engine.tessellation_report
      expect(report[:total_mosaics]).to eq(2)
    end
  end

  describe '#expand_tile' do
    it 'expands an existing tile' do
      tile = engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      result = engine.expand_tile(tile_id: tile.id)
      expect(result.coverage).to be > 0.0
    end

    it 'returns nil for unknown tile' do
      expect(engine.expand_tile(tile_id: 'nonexistent')).to be_nil
    end
  end

  describe '#shrink_all!' do
    it 'reduces coverage of all tiles' do
      tile = engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      engine.shrink_all!
      expect(tile.coverage).to be < 0.5
    end
  end

  describe '#connect_tiles' do
    it 'connects two tiles' do
      t1 = engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      t2 = engine.create_tile(tile_type: :skill, shape: :square, domain: :emotional)
      result = engine.connect_tiles(tile_a_id: t1.id, tile_b_id: t2.id)
      expect(result[:connected]).to be true
    end

    it 'returns nil for missing tiles' do
      t1 = engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      expect(engine.connect_tiles(tile_a_id: t1.id, tile_b_id: 'missing')).to be_nil
    end
  end

  describe 'query methods' do
    before do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      engine.create_tile(tile_type: :skill, shape: :square, domain: :emotional, coverage: 0.3)
      engine.create_tile(tile_type: :pattern, shape: :hexagonal, domain: :cognitive, coverage: 0.8)
    end

    it 'filters tiles_by_domain' do
      expect(engine.tiles_by_domain(domain: :cognitive).size).to eq(2)
    end

    it 'filters tiles_by_type' do
      expect(engine.tiles_by_type(tile_type: :knowledge).size).to eq(1)
    end

    it 'filters tiles_by_shape' do
      expect(engine.tiles_by_shape(shape: :hexagonal).size).to eq(2)
    end

    it 'returns most_covered tiles' do
      results = engine.most_covered(limit: 2)
      expect(results.size).to eq(2)
      expect(results.first.coverage).to be >= results.last.coverage
    end

    it 'returns least_covered tiles' do
      results = engine.least_covered(limit: 1)
      expect(results.size).to eq(1)
    end
  end

  describe 'aggregate metrics' do
    it 'returns 0.0 overall_coverage for empty engine' do
      expect(engine.overall_coverage).to eq(0.0)
    end

    it 'returns 0.0 overall_fit for empty engine' do
      expect(engine.overall_fit).to eq(0.0)
    end

    it 'computes overall_coverage from mosaics' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.6)
      expect(engine.overall_coverage).to be > 0.0
    end

    it 'computes overall_fit from tiles' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      expect(engine.overall_fit).to be > 0.0
    end

    it 'computes gap_density' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, fit_score: 0.1)
      expect(engine.gap_density).to be > 0.0
    end
  end

  describe '#tessellation_report' do
    it 'returns comprehensive report' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      report = engine.tessellation_report
      expect(report).to include(:total_tiles, :total_mosaics, :overall_coverage,
                                :coverage_label, :overall_fit, :fit_label,
                                :overall_coherence, :gap_density, :domain_coverage, :mosaics)
    end

    it 'includes coverage_label' do
      engine.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      report = engine.tessellation_report
      expect(report[:coverage_label]).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      h = engine.to_h
      expect(h).to include(:total_tiles, :total_mosaics, :coverage, :fit, :coherence)
    end
  end
end
