require_relative 'spec_helper'
require_relative '../lib/spoonerise'

describe Flipper do
  context 'when initialized' do
    let(:error) { 'Not enough words to flip' }
    context 'with not enough flip-able words' do
      it { expect { Flipper.new(%w(hello)) }.to raise_error(error) }
      it { expect { Flipper.new(%w(a thing)) }.to raise_error(error) }
    end
    context 'with the words "the ultimate spoonerise test"' do
      let(:words) { %w(the ultimate spoonerise test) }
      context 'and excluding too many words' do
        let(:rev_excl) do
          Flipper.new(words, {reverse: true, exclude: %w(the ultimate test)})
        end
        it { expect { rev_excl }.to raise_error(error) }
      end
      context 'and no options' do
        let(:normal) { Flipper.new(words) }
        it { expect { normal }.not_to raise_error }
        it { expect(normal.spoonerise).to eq(%w(e spultimate toonerise thest)) }
        it { expect(normal.to_s).to eq('e spultimate toonerise thest') }
      end
      context 'and reversed' do
        let(:reversed) { Flipper.new(words, {reverse: true}) }
        it { expect { reversed }.not_to raise_error }
        it { expect(reversed.spoonerise).to eq(%w(te thultimate oonerise spest)) }
        it { expect(reversed.to_s).to eq('te thultimate oonerise spest') }
      end
      context 'and excluding "test"' do
        let(:excluding) { Flipper.new(words, {exclude: %w(test)}) }
        it { expect { excluding }.not_to raise_error }
        it { expect(excluding.spoonerise).to eq(%w(e spultimate thoonerise test)) }
        it { expect(excluding.to_s).to eq('e spultimate thoonerise test') }
      end
      context 'and reversed, excluding "test"' do
        let(:rev_excl) { Flipper.new(words, {reverse: true, exclude: %w(test)}) }
        it { expect { rev_excl }.not_to raise_error }
        it { expect(rev_excl.spoonerise).to eq(%w(spe thultimate oonerise test)) }
        it { expect(rev_excl.to_s).to eq('spe thultimate oonerise test') }
      end
      context 'and lazy' do
        let(:lazy) { Flipper.new(words, {lazy: true}) }
        it { expect { lazy }.not_to raise_error }
        it { expect(lazy.spoonerise).to eq(%w(the spultimate toonerise est)) }
        it { expect(lazy.to_s).to eq('the spultimate toonerise est') }
      end
      context 'and lazy, excluding "test"' do
        let(:lazy_excl) { Flipper.new(words, {lazy: true, exclude: %w(test)}) }
        it { expect { lazy_excl }.not_to raise_error }
        it { expect(lazy_excl.spoonerise).to eq(%w(the spultimate oonerise test)) }
        it { expect(lazy_excl.to_s).to eq('the spultimate oonerise test') }
      end
      context 'and lazy, reversed' do
        let(:lazy_rev) { Flipper.new(words, {lazy: true, reverse: true}) }
        it { expect { lazy_rev }.not_to raise_error }
        it { expect(lazy_rev.spoonerise).to eq(%w(the tultimate oonerise spest)) }
        it { expect(lazy_rev.to_s).to eq('the tultimate oonerise spest') }
      end
      context 'and lazy, reversed, excluding "test"' do
        let(:lazy_excl_rev) { Flipper.new(words, {lazy: true, reverse: true, exclude: %w(test)}) }
        it { expect { lazy_excl_rev }.not_to raise_error }
        it { expect(lazy_excl_rev.spoonerise).to eq(%w(the spultimate oonerise test)) }
        it { expect(lazy_excl_rev.to_s).to eq('the spultimate oonerise test') }
      end
    end
  end
end

