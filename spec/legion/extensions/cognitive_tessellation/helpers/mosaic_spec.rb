# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveTessellation::Helpers::Mosaic do
  subject(:mosaic) { described_class.new(domain: :cognitive) }

  let(:tile_class) { Legion::Extensions::CognitiveTessellation::Helpers::Tile }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(mosaic.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores domain as symbol' do
      expect(mosaic.domain).to eq(:cognitive)
    end

    it 'starts with empty tiles' do
      expect(mosaic.tiles).to be_empty
    end
  end

  describe '#add_tile' do
    it 'adds a tile to the mosaic' do
      tile = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
      mosaic.add_tile(tile)
      expect(mosaic.tiles.size).to eq(1)
    end

    it 'auto-connects tiles of the same domain' do
      t1 = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      t2 = tile_class.new(tile_type: :skill, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      mosaic.add_tile(t1)
      mosaic.add_tile(t2)
      expect(t2.adjacent_ids).to include(t1.id)
    end
  end

  describe '#total_coverage' do
    it 'returns 0.0 for empty mosaic' do
      expect(mosaic.total_coverage).to eq(0.0)
    end

    it 'returns average effective coverage' do
      t1 = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.6)
      t2 = tile_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.4)
      mosaic.add_tile(t1)
      mosaic.add_tile(t2)
      expect(mosaic.total_coverage).to be_between(0.0, 1.0)
    end
  end

  describe '#average_fit' do
    it 'returns 0.0 for empty mosaic' do
      expect(mosaic.average_fit).to eq(0.0)
    end

    it 'computes average fit score' do
      t1 = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, fit_score: 0.8)
      mosaic.add_tile(t1)
      expect(mosaic.average_fit).to be > 0.0
    end
  end

  describe '#coherence' do
    it 'returns 0.0 for empty mosaic' do
      expect(mosaic.coherence).to eq(0.0)
    end
  end

  describe '#uniformity' do
    it 'returns 1.0 for single tile' do
      t = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      mosaic.add_tile(t)
      expect(mosaic.uniformity).to eq(1.0)
    end

    it 'returns high uniformity for similar coverages' do
      t1 = tile_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      t2 = tile_class.new(tile_type: :skill, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
      mosaic.add_tile(t1)
      mosaic.add_tile(t2)
      expect(mosaic.uniformity).to be > 0.9
    end
  end

  describe '#complete?' do
    it 'returns false for low coverage' do
      expect(mosaic).not_to be_complete
    end
  end

  describe '#to_h' do
    it 'returns hash with mosaic stats' do
      h = mosaic.to_h
      expect(h).to include(:id, :domain, :tile_count, :total_coverage, :average_fit,
                            :coherence, :uniformity, :gaps, :seamless, :complete)
    end
  end
end
