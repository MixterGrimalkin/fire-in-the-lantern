require_relative '../../lib/utils'

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

end