require_relative '../../app/lib/utils'

RSpec.describe 'Utils Module' do
  include Utils

  context '#symbolize_keys' do
    let(:hash_before) do
      {'a' => 123,
       'b' => {
           'c' => 13234,
           'd' => {
               'e' => 4259,
               'f' => [{'g' => 54, 'f' => ['h' => 1]}]
           }}}
    end
    let(:hash_after) do
      {a: 123,
       b: {
           c: 13234,
           d: {
               e: 4259,
               f: [{g: 54, f: [h: 1]}]
           }}}
    end
    it 'symbolizes keys' do
      expect(symbolize_keys(hash_before)).to eq hash_after
    end
  end

  context 'array utils' do
    let(:array) { [1, 2, 3, 4] }
    it '#sum_array' do
      expect(sum_array(array)).to eq 10
    end
    it '#avg_array' do
      expect(avg_array(array)).to eq 2.5
    end
  end

  context '#pick_from' do
    let(:items) { %w(One Two Three Four Five) }
    let(:menu) { "1. One\n2. Two\n3. Three\n4. Four\n5. Five\n" }
    it 'prints the menu and returns the item' do
      allow(STDIN).to receive(:getch).and_return('2')
      expect { @choice = pick_from items }.to output(menu).to_stdout
      expect(@choice).to eq 'Two'
    end
    it 'returns nil if option unknown' do
      allow(STDIN).to receive(:getch).and_return('X')
      expect { @choice = pick_from items }.to output(menu).to_stdout
      expect(@choice).to be_nil
    end
  end

  context '#print_table' do
    let(:data) do
      [[:base, 'base layer', 99],
       [:another, 'swirly layer'],
       [:bum, 'nifty layer', 1]]
    end
    let(:table) do
      "base     base layer    99\n" \
      "another  swirly layer\n" \
      "bum      nifty layer   1 \n"
    end
    it 'prints a table' do
      expect{ print_table(data) }.to output(table).to_stdout
    end
  end

end