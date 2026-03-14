# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveTessellation::Helpers::Tile do
  subject(:tile) { described_class.new(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(tile.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores tile_type as symbol' do
      expect(tile.tile_type).to eq(:knowledge)
    end

    it 'stores shape as symbol' do
      expect(tile.shape).to eq(:hexagonal)
    end

    it 'stores domain as symbol' do
      expect(tile.domain).to eq(:cognitive)
    end

    it 'defaults coverage to 0.0' do
      expect(tile.coverage).to eq(0.0)
    end

    it 'defaults fit_score to 0.5' do
      expect(tile.fit_score).to eq(0.5)
    end

    it 'starts with empty adjacent_ids' do
      expect(tile.adjacent_ids).to be_empty
    end

    it 'accepts explicit coverage' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :emotional, coverage: 0.8)
      expect(t.coverage).to eq(0.8)
    end

    it 'clamps coverage to 0..1' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :emotional, coverage: 1.5)
      expect(t.coverage).to eq(1.0)
    end
  end

  describe '#expand!' do
    it 'increases coverage' do
      tile.expand!
      expect(tile.coverage).to be > 0.0
    end

    it 'clamps coverage at 1.0' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.98)
      t.expand!(0.1)
      expect(t.coverage).to eq(1.0)
    end
  end

  describe '#shrink!' do
    it 'decreases coverage' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.5)
      t.shrink!
      expect(t.coverage).to be < 0.5
    end

    it 'clamps coverage at 0.0' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.01)
      t.shrink!(0.1)
      expect(t.coverage).to eq(0.0)
    end
  end

  describe '#adjust_fit!' do
    it 'updates fit_score' do
      tile.adjust_fit!(0.9)
      expect(tile.fit_score).to eq(0.9)
    end

    it 'clamps fit_score' do
      tile.adjust_fit!(1.5)
      expect(tile.fit_score).to eq(1.0)
    end
  end

  describe '#connect!' do
    it 'adds adjacent id' do
      tile.connect!('other-id')
      expect(tile.adjacent_ids).to include('other-id')
    end

    it 'does not duplicate adjacent ids' do
      tile.connect!('other-id')
      tile.connect!('other-id')
      expect(tile.adjacent_ids.size).to eq(1)
    end
  end

  describe 'predicate methods' do
    it 'reports full_coverage when coverage >= 0.95' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.96)
      expect(t).to be_full_coverage
    end

    it 'reports gapped when fit_score < 0.3' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, fit_score: 0.2)
      expect(t).to be_gapped
    end

    it 'reports isolated when no adjacent tiles' do
      expect(tile).to be_isolated
    end

    it 'reports well_connected with 3+ adjacent' do
      3.times { |i| tile.connect!("id-#{i}") }
      expect(tile).to be_well_connected
    end

    it 'reports seamless when fit >= 0.8' do
      tile.adjust_fit!(0.85)
      expect(tile).to be_seamless
    end
  end

  describe '#effective_coverage' do
    it 'equals coverage for non-overlapping tiles' do
      t = described_class.new(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.5)
      expect(t.effective_coverage).to eq(0.5)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all fields' do
      h = tile.to_h
      expect(h).to include(:id, :tile_type, :shape, :domain, :coverage, :fit_score,
                           :effective_coverage, :adjacent_count, :created_at)
    end
  end
end
