require 'spec_helper'

describe Lita::Handlers::OnewheelBaileys, lita_handler: true do
  it { is_expected.to route_command('taps') }
  it { is_expected.to route_command('taps 4') }

  before do
    mock = File.open('spec/fixtures/baileys.html').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_command 'taps'
    expect(replies.last).to eq("Bailey's taps: 1) Cider Riot! Plastic Paddy  2) Fox Tail Rosenberry  Cask 3) Machine House Crystal Maze  4) Wild Ride Solidarity  5) Mazama Gillian’s Red  Nitro 6) Backwoods Winchester Brown  7) Fort George Vortex  8) Fat Head’s Zeus Juice  9) Hopworks Noggin’ Floggin’  10) Anderson Valley Briney Melon Gose  11) Lagunitas Copper Fusion Ale  12) Double Mountain Fast Lane  13) Burnside Couch Lager  14) Bell’s Oatmeal Stout  15) Baerlic Wildcat  16) New Belgium La Folie  17) Culmination Urizen  18) Knee Deep Hop Surplus  19) Cascade Lakes Ziggy Stardust  20) Knee Deep Dark Horse  21) Coronado Orange Avenue Wit  22) GoodLife 29er  23) Amnesia Slow Train Porter  24) Oakshire Perfect Storm  25) Green Flash Passion Fruit Kicker")
  end

  it 'displays details for tap 4' do
    send_command 'taps 4'
    expect(replies.last).to eq('Bailey\'s tap 4) Wild Ride Solidarity - Abbey Dubbel – Barrel Aged (Pinot Noir) 8.2%, 4oz Pour – $4 | 12oz – $7, 26% remaining')
  end

  it 'doesn\'t explode on 1' do
    send_command 'taps 1'
    expect(replies.count).to eq(1)
    expect(replies.last).to eq('Bailey\'s tap 1) Cider Riot! Plastic Paddy - Apple Cider w/ Irish tea 6.0%, 10oz – $4 | 20oz – $7 | 32oz Crowler $10, 48% remaining')
  end

  it 'gets nitro' do
    send_command 'taps nitro'
    expect(replies.last).to eq('Bailey\'s tap Nitro 6) Backwoods Winchester Brown - Brown Ale 6.2%, 10oz – $3 | 20oz – $5, 98% remaining')
  end

  it 'gets cask' do
    send_command 'taps cask'
    expect(replies.last).to eq('Bailey\'s tap Cask 3) Machine House Crystal Maze - ESB 4.0%, 10oz – $3 | 20oz – $5, 57% remaining')
  end

  it 'searches for ipa' do
    send_command 'taps ipa'
    expect(replies.last).to eq("Bailey's tap 24) Oakshire Perfect Storm - Imperial IPA 9.0%, 10oz – $4 | 20oz – $6 | 32oz Crowler $10, 61% remaining")
  end

  it 'searches for brown' do
    send_command 'taps brown'
    expect(replies.last).to eq("Bailey's tap 22) GoodLife 29er - India Brown Ale 6.0%, 10oz – $3 | 20oz – $5 | 32oz Crowler $8, 37% remaining")
  end
end
