require 'spec_helper'

describe Lita::Handlers::OnewheelBaileys, lita_handler: true do
  it { is_expected.to route_command('taps') }
  it { is_expected.to route_command('taps 4') }

  before do
    mock = File.open('spec/fixtures/baileys.json').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'taps'
    expect(replies.last).to eq('Tidebreak, The Sunny Cider, Knee Deep Twisted Barre, Golden Valley Barrel-Aged Old Relic, Fat Head\'s Semper FiPA, Stone Vertical Epic 11.11.11, Lagunitas Olde Gnarleywine, Sasquatch Vanilla Bourbon Creme Ale, Culmination Forbidden Rice, Airways Test Pilot, Everybody\'s Local Logger, Rogue Charlie, Elysian Hawaiian Sunburn, Epic Straight Up Saison, Flat Tail Bulletproof Zest, Ballast Point Watermelon Dorado, Three Magnets Belgian Pale Ale, Backwoods Bourbon Stout, Barley Brown\'s Coyote Peak Wheat, pFriem Cascadian Dark Ale, Flat Tail 6 A.M. Stout, Barley Brown\'s Tank Slapper, Uinta Ready Set Gose, Machine House Winter Warmer, Boulder Shake')
  end

  it 'displays details for tap 4' do
    send_command 'taps 4'
    expect(replies.last).to eq('Knee Deep Twisted Barre Dubbel, 73.65322580645163% full.  Served in a Nonic glass.')
  end
end
