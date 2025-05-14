# frozen_string_literal: true

RSpec.describe Uncov::Report::File::Line do
  subject(:line) { described_class.new(number:, content:, simplecov:, nocov:, context:, git_diff:) }

  let(:number) { 1 }
  let(:content) { 'line content' }
  let(:simplecov) { true }
  let(:nocov) { nil }
  let(:context) { 1 }
  let(:git_diff) { nil }

  describe '#nocov' do
    subject { line.nocov }

    context 'with nocov' do
      let(:nocov) { true }

      context 'with nocov_ignore true' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(true) }

        it { is_expected.to be_falsy }
      end

      context 'with nocov_ignore false' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(false) }

        it { is_expected.to be_truthy }
      end
    end

    context 'without nocov' do
      let(:nocov) { nil }

      context 'with nocov_ignore true' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(true) }

        it { is_expected.to be_falsy }
      end

      context 'with nocov_ignore false' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(false) }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#uncov?' do
    subject { line.uncov? }

    context 'with simplecov true' do
      let(:simplecov) { true }

      context 'with nocov' do
        let(:nocov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without nocov' do
        let(:nocov) { nil }

        it { is_expected.to be_falsy }
      end
    end

    context 'with simplecov false' do
      let(:simplecov) { false }

      context 'with nocov' do
        let(:nocov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without nocov' do
        let(:nocov) { nil }

        it { is_expected.to be_truthy }
      end
    end

    context 'without simplecov' do
      let(:simplecov) { nil }

      context 'with nocov' do
        let(:nocov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without nocov' do
        let(:nocov) { nil }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#covered?' do
    subject { line.covered? }

    context 'with nocov_covered false and nocov_ignore false' do
      before { allow(Uncov.configuration).to receive_messages(nocov_covered: false, nocov_ignore: false) }

      context 'with simplecov true' do
        let(:simplecov) { true }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_truthy }
        end
      end

      context 'with simplecov false' do
        let(:simplecov) { false }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'without simplecov' do
        let(:simplecov) { nil }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_falsy }
        end
      end
    end

    context 'with nocov_covered true, nocov_ignore false and nocov true' do
      let(:nocov) { true }

      before { allow(Uncov.configuration).to receive_messages(nocov_covered: true, nocov_ignore: false) }

      context 'with simplecov true' do
        let(:simplecov) { true }

        it { is_expected.to be_falsy }
      end

      context 'with simplecov false' do
        let(:simplecov) { false }

        it { is_expected.to be_truthy }
      end
    end

    context 'with nocov_covered true, nocov_ignore true and nocov true' do
      let(:nocov) { true }

      before { allow(Uncov.configuration).to receive_messages(nocov_covered: true, nocov_ignore: true) }

      context 'with simplecov true' do
        let(:simplecov) { true }

        it { is_expected.to be_falsy }
      end

      context 'with simplecov false' do
        let(:simplecov) { false }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#nocov_covered?' do
    subject { line.nocov_covered? }

    context 'with nocov_covered true' do
      before { allow(Uncov.configuration).to receive(:nocov_covered).and_return(true) }

      context 'with simplecov true' do
        let(:simplecov) { true }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_truthy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'with simplecov false' do
        let(:simplecov) { false }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'without simplecov' do
        let(:simplecov) { nil }

        context 'with nocov' do
          let(:nocov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without nocov' do
          let(:nocov) { nil }

          it { is_expected.to be_falsy }
        end
      end
    end
  end

  describe '#trigger?' do
    subject { line.trigger? }

    context 'when does not trigger' do
      let(:nocov) { true }
      let(:simplecov) { false }

      it { is_expected.to be_falsy }
    end

    context 'when triggers because of uncov?' do
      let(:nocov) { nil }
      let(:simplecov) { false }

      it { is_expected.to be_truthy }
    end

    context 'when triggers because of nocov_covered?' do
      let(:nocov) { true }
      let(:simplecov) { true }

      before { allow(Uncov.configuration).to receive(:nocov_covered).and_return(true) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#display?' do
    subject { line.display? }

    context 'when does not display' do
      let(:context) { false }
      let(:nocov) { true }
      let(:simplecov) { true }

      it { is_expected.to be_falsy }
    end

    context 'when displays because of context' do
      let(:context) { true }
      let(:nocov) { true }
      let(:simplecov) { true }

      it { is_expected.to be_truthy }
    end

    context 'when displays because of trigger' do
      let(:context) { true }
      let(:nocov) { true }
      let(:simplecov) { false }

      it { is_expected.to be_truthy }
    end
  end

  describe '#relevant?' do
    subject { line.relevant? }

    context 'when not relevant' do
      let(:nocov) { true }
      let(:simplecov) { false }

      it { is_expected.to be_falsy }
    end

    context 'when relevant because of trigger' do
      let(:nocov) { nil }
      let(:simplecov) { false }

      it { is_expected.to be_truthy }
    end

    context 'when relevant because of coverage' do
      let(:nocov) { nil }
      let(:simplecov) { true }

      it { is_expected.to be_truthy }
    end
  end
end
