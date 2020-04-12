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
    let(:menu) { "1. One\n2. Two\n3. Three\n4. Four\n5. Five\n\n" }

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

    context 'where there are more that nine options' do
      let(:more_items) { %w(a b c d e f g h i j k) }
      let(:menu_first_page) { "1. a\n2. b\n3. c\n4. d\n5. e\n6. f\n7. g\n8. h\n9. i\n0. more...\n\n" }
      let(:menu_all) { "1. a\n2. b\n3. c\n4. d\n5. e\n6. f\n7. g\n8. h\n9. i\n0. more...\n\n1. j\n2. k\n\n" }

      it 'selects an item from the first page' do
        allow(STDIN).to receive(:getch).and_return('2')
        expect { @choice = pick_from more_items }.to output(menu_first_page).to_stdout
        expect(@choice).to eq 'b'
      end

      it 'selects an item from the second page' do
        allow(STDIN).to receive(:getch).and_return('0', '2')
        expect { @choice = pick_from more_items }.to output(menu_all).to_stdout
        expect(@choice).to eq 'k'
      end
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