require 'oystercard'

describe Oystercard do
  let(:entry_station) { double :station }
  let(:exit_station)  { double :station }

  it 'should be able to test that a freshly initialized card has a balance of 0 by default' do
    expect(subject.balance).to eq Oystercard::DEFAULT_BALANCE
  end

  it "should enable an oystercard's balance to be topped up" do
    top_up_amount = 10
    subject.top_up(top_up_amount)
    expect(subject.balance).to eq top_up_amount
  end

  it 'should have an empty list of journeys by default' do
    expect(subject.list_of_journeys).to eq []
  end

  it 'should add a complete journey to the list of journeys if a card touches in AND out' do
    card = Oystercard.new(20)
    card.touch_in(entry_station)
    card.touch_out(exit_station)
    expect(card.list_of_journeys[0]).to eq({entry_station: entry_station, exit_station: exit_station})
  end

  describe '#top_up' do
    it "should raise an error when top_up_amount would cause card's balance to exceed maximum balance" do
      expect { subject.top_up(Oystercard::MAX_BALANCE + 1) }.to raise_error(BalanceError)
    end
  end

  describe '#deduct' do
    it 'should be able to deduct an amount from card balance' do
      top_up_amount = 10
      debit_amount = 5
      card = Oystercard.new(top_up_amount)
      card.deduct(debit_amount)
      expect(card.balance).to eq(top_up_amount - debit_amount)
    end
  end

  describe '#touch_in' do
    before(:each) { @card = Oystercard.new(20) }

    it 'should be able to touch in at barrier' do
      @card.touch_in(entry_station)
      expect(@card.entry_station).to eq entry_station
    end

    it 'should raise an error if balance is below minimum balance' do
      card = Oystercard.new
      expect { card.touch_in entry_station }.to raise_error(BalanceError)
    end

    it 'should be able to remember entry station after touch in' do
      @card.touch_in(entry_station)
      expect(@card.entry_station).to eq entry_station
    end
  end

  describe '#touch_out' do
    before(:each) { @card = Oystercard.new(20) }

    it 'should be able to touch out at barrier' do
      @card.touch_in(entry_station)
      @card.touch_out(exit_station)
      expect(@card.entry_station).to eq nil
    end

    it 'should be able to update balance with reduced balance' do
      minimum_fare = Oystercard::MIN_FARE
      expect{ @card.deduct(minimum_fare) }.to change{ @card.balance }.by(-minimum_fare)
    end

    it 'should erase record of touched in station' do
      @card.touch_in(entry_station)
      @card.touch_out(exit_station)
      expect(@card.entry_station).to eq nil
    end
  end

end
