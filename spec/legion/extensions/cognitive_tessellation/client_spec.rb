# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveTessellation::Client do
  subject(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:create_tile, :expand_tile, :tessellation_status)
  end

  it 'runs a full tessellation lifecycle' do
    result = client.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.3)
    tile_id = result[:tile][:id]

    client.expand_tile(tile_id: tile_id)
    client.create_tile(tile_type: :skill, shape: :square, domain: :cognitive, coverage: 0.5)

    status = client.tessellation_status
    expect(status[:total_tiles]).to eq(2)
    expect(status[:success]).to be true
  end

  it 'lists gaps' do
    client.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, fit_score: 0.1)
    gaps = client.list_gaps
    expect(gaps[:count]).to eq(1)
  end

  it 'connects tiles across domains' do
    r1 = client.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive)
    r2 = client.create_tile(tile_type: :skill, shape: :square, domain: :emotional)
    result = client.connect_tiles(tile_a_id: r1[:tile][:id], tile_b_id: r2[:tile][:id])
    expect(result[:success]).to be true
  end

  it 'shrinks all tiles' do
    client.create_tile(tile_type: :knowledge, shape: :hexagonal, domain: :cognitive, coverage: 0.5)
    result = client.shrink_all
    expect(result[:success]).to be true
  end
end
