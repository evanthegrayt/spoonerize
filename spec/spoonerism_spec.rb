require_relative 'spec_helper'
require_relative '../lib/spoonerise'

describe Spoonerise::Spoonerism do
  context 'when initialized' do
    let(:error) { 'Not enough words to flip' }

    context 'with not enough flip-able words' do
      it { expect { Spoonerise::Spoonerism.new(%w(hello)) }.to raise_error(error) }
      it { expect { Spoonerise::Spoonerism.new(%w(hello)) }.to raise_error(Spoonerise::JakPibError) }
      it { expect { Spoonerise::Spoonerism.new(%w(his and hers)) { |s| s.lazy = true} }.to raise_error(Spoonerise::JakPibError) }
    end

    context 'with the words "the ultimate spoonerise test"' do
      let(:words) { %w(the ultimate spoonerise test) }
      context 'and excluding too many words' do
        let(:too_many_excl) do
          Spoonerise::Spoonerism.new(words) do |s|
            s.reverse = true
            s.excluded_words = %w[the ultimate test]
          end
        end
        it { expect { too_many_excl }.to raise_error(error) }
      end

      context 'and no options' do
        let(:normal) { Spoonerise::Spoonerism.new(words) }
        it { expect { normal }.not_to raise_error }
        it { expect(normal.spoonerise).to eq(%w(e spultimate toonerise thest)) }
        it { expect(normal.to_s).to eq('e spultimate toonerise thest') }
        it { expect(normal.to_h).to eq(
          {'the'=>'e', 'ultimate'=>'spultimate', 'spoonerise'=>'toonerise', 'test'=>'thest'}) }
        # TODO, just test a file is written.
        context 'and the instance is saved' do
          let(:saved) { Spoonerise::Spoonerism.new(words) { |s| s.save = true} }
          # it { expect { saved.save }.to output(/INFO -- :/).to_stdout }
        end
      end

      context 'and reversed' do
        let(:reversed) { Spoonerise::Spoonerism.new(words) { |s| s.reverse = true } }
        it { expect { reversed }.not_to raise_error }
        it { expect(reversed.spoonerise).to eq(%w(te thultimate oonerise spest)) }
        it { expect(reversed.to_s).to eq('te thultimate oonerise spest') }
        it { expect(reversed.to_h).to eq(
          {'spoonerise' => 'oonerise', 'test' => 'spest', 'the' => 'te', 'ultimate' => 'thultimate'}) }
      end

      context 'and excluding "test"' do
        let(:excluding) { Spoonerise::Spoonerism.new(words) { |s| s.excluded_words = %w[test] } }
        it { expect { excluding }.not_to raise_error }
        it { expect(excluding.spoonerise).to eq(%w(e spultimate thoonerise test)) }
        it { expect(excluding.to_s).to eq('e spultimate thoonerise test') }
        it { expect(excluding.to_h).to eq(
          {'spoonerise' => 'thoonerise', 'test' => 'test', 'the' => 'e', 'ultimate' => 'spultimate' }) }
      end

      context 'and reversed, excluding "test"' do
        let(:rev_excl) do
          Spoonerise::Spoonerism.new(words) do |s|
            s.reverse = true
            s.excluded_words = %w[test]
          end
        end
        it { expect { rev_excl }.not_to raise_error }
        it { expect(rev_excl.spoonerise).to eq(%w(spe thultimate oonerise test)) }
        it { expect(rev_excl.to_s).to eq('spe thultimate oonerise test') }
        it { expect(rev_excl.to_h).to eq(
          {'spoonerise' => 'oonerise', 'test' => 'test', 'the' => 'spe', 'ultimate' => 'thultimate' }) }
      end

      context 'and lazy' do
        let(:lazy) { Spoonerise::Spoonerism.new(words) { |s| s.lazy = true} }
        it { expect { lazy }.not_to raise_error }
        it { expect(lazy.spoonerise).to eq(%w(the spultimate toonerise est)) }
        it { expect(lazy.to_s).to eq('the spultimate toonerise est') }
        it { expect(lazy.to_h).to eq(
          {'spoonerise' => 'toonerise', 'test' => 'est', 'the' => 'the', 'ultimate' => 'spultimate' }) }
      end

      context 'and lazy, excluding "test"' do
        let(:lazy_excl) do
          Spoonerise::Spoonerism.new(words) do |s|
            s.lazy = true
            s.excluded_words = %w[test]
          end
        end
        it { expect { lazy_excl }.not_to raise_error }
        it { expect(lazy_excl.spoonerise).to eq(%w(the spultimate oonerise test)) }
        it { expect(lazy_excl.to_s).to eq('the spultimate oonerise test') }
        it { expect(lazy_excl.to_h).to eq(
          {'spoonerise' => 'oonerise', 'test' => 'test', 'the' => 'the', 'ultimate' => 'spultimate'}) }
      end

      context 'and lazy, reversed' do
        let(:lazy_rev) do
          Spoonerise::Spoonerism.new(words) do |s|
            s.lazy = true
            s.reverse = true
          end
        end
        it { expect { lazy_rev }.not_to raise_error }
        it { expect(lazy_rev.spoonerise).to eq(%w(the tultimate oonerise spest)) }
        it { expect(lazy_rev.to_s).to eq('the tultimate oonerise spest') }
        it { expect(lazy_rev.to_h).to eq(
          {'spoonerise' => 'oonerise', 'test' => 'spest', 'the' => 'the', 'ultimate' => 'tultimate' }) }
      end

      context 'and lazy, reversed, excluding "test"' do
        let(:lazy_excl_rev) do
          Spoonerise::Spoonerism.new(words) do |s|
            s.lazy = true
            s.reverse = true
            s.excluded_words = %w(test)
          end
        end
        it { expect { lazy_excl_rev }.not_to raise_error }
        it { expect(lazy_excl_rev.spoonerise).to eq(%w(the spultimate oonerise test)) }
        it { expect(lazy_excl_rev.to_s).to eq('the spultimate oonerise test') }
        it { expect(lazy_excl_rev.to_h).to eq(
          {'spoonerise' => 'oonerise', 'test' => 'test', 'the' => 'the', 'ultimate' => 'spultimate'}) }
      end
    end
  end
end
