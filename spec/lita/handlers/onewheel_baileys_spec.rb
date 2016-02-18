require 'spec_helper'

describe Lita::Handlers::OnewheelBaileys, lita_handler: true do
  it { is_expected.to route('taps') }
  it { is_expected.to route('taps 4') }

  before do
    mock = File.open('spec/fixtures/baileys.json').read
    allow(RestClient).to receive(:get) { mock }
  end

  it 'shows the taps' do
    send_message 'taps'
    expect(replies.last).to eq('x')
  end

  it 'displays details for tap 4' do
    send_message 'taps 4'
    expect(replies.last).to eq('y')
  end
end
