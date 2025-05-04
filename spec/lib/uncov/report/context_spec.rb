# frozen_string_literal: true

RSpec.describe Uncov::Report::Context do
  subject { described_class.calculate(all_line_numbers, important_line_numbers, context) }

  let(:all_line_numbers) { [1, 2, 3, 4, 5] }

  context 'when last line context=3' do
    let(:context) { 3 }
    let(:important_line_numbers) { [5] }

    it { is_expected.to eq([2, 3, 4]) }
  end

  context 'when first line context=2' do
    let(:context) { 2 }
    let(:important_line_numbers) { [1] }

    it { is_expected.to eq([2, 3]) }
  end

  context 'when consecutive lines context=1' do
    let(:context) { 1 }
    let(:important_line_numbers) { [3, 4] }

    it { is_expected.to eq([2, 5]) }
  end

  context 'when gap between important_line_numbers' do
    let(:context) { 1 }
    let(:important_line_numbers) { [1, 5] }

    context 'with context=1' do
      let(:context) { 1 }

      it { is_expected.to eq([2, 4]) }
    end

    context 'with context=2' do
      let(:context) { 2 }

      it { is_expected.to eq([2, 3, 4]) }
    end
  end
end
