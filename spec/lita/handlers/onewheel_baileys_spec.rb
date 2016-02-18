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
    expect(replies.last).to eq("1) Tidebreak, 2) The Sunny Cider, 4) Knee Deep Twisted Barre, 5) Golden Valley Barrel-Aged Old Relic, 7) Fat Head's Semper FiPA, 8) Stone Vertical Epic 11.11.11, 9) Lagunitas Olde Gnarleywine, 10) Sasquatch Vanilla Bourbon Creme Ale, 11) Culmination Forbidden Rice, 12) Airways Test Pilot, 13) Everybody's Local Logger, 14) Rogue Charlie, 15) Elysian Hawaiian Sunburn, 16) Epic Straight Up Saison, 17) Flat Tail Bulletproof Zest, 18) Ballast Point Watermelon Dorado, 19) Three Magnets Belgian Pale Ale, 20) Backwoods Bourbon Stout, 21) Barley Brown's Coyote Peak Wheat, 22) pFriem Cascadian Dark Ale, 23) Flat Tail 6 A.M. Stout, 24) Barley Brown's Tank Slapper, 25) Uinta Ready Set Gose, Cask 3) Machine House Winter Warmer, Nitro 6) Boulder Shake")
  end

  it 'displays details for tap 4' do
    send_command 'taps 4'
    expect(replies.last).to eq('Knee Deep Twisted Barre Dubbel, 73.65322580645163% full.  Served in a Nonic glass.  $5.00/$3.00')
  end
end
