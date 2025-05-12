# frozen_string_literal: true

RSpec.describe Uncov::Report::File::Line do
  subject(:line) { described_class.new(number:, content:, simple_cov:, no_cov:, context:, git_diff:) }

  let(:number) { 1 }
  let(:content) { 'line content' }
  let(:simple_cov) { true }
  let(:no_cov) { nil }
  let(:context) { 1 }
  let(:git_diff) { nil }

  describe '#no_cov' do
    subject { line.no_cov }

    context 'with no_cov' do
      let(:no_cov) { true }

      context 'with nocov_ignore true' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(true) }

        it { is_expected.to be_falsy }
      end

      context 'with nocov_ignore false' do
        before { allow(Uncov.configuration).to receive(:nocov_ignore).and_return(false) }

        it { is_expected.to be_truthy }
      end
    end

    context 'without no_cov' do
      let(:no_cov) { nil }

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

    context 'with simple_cov true' do
      let(:simple_cov) { true }

      context 'with no_cov' do
        let(:no_cov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without no_cov' do
        let(:no_cov) { nil }

        it { is_expected.to be_falsy }
      end
    end

    context 'with simple_cov false' do
      let(:simple_cov) { false }

      context 'with no_cov' do
        let(:no_cov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without no_cov' do
        let(:no_cov) { nil }

        it { is_expected.to be_truthy }
      end
    end

    context 'without simple_cov' do
      let(:simple_cov) { nil }

      context 'with no_cov' do
        let(:no_cov) { true }

        it { is_expected.to be_falsy }
      end

      context 'without no_cov' do
        let(:no_cov) { nil }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#covered?' do
    subject { line.covered? }

    context 'with nocov_covered false and nocov_ignore false' do
      before { allow(Uncov.configuration).to receive_messages(nocov_covered: false, nocov_ignore: false) }

      context 'with simple_cov true' do
        let(:simple_cov) { true }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_truthy }
        end
      end

      context 'with simple_cov false' do
        let(:simple_cov) { false }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'without simple_cov' do
        let(:simple_cov) { nil }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_falsy }
        end
      end
    end

    context 'with nocov_covered true, nocov_ignore false and nocov true' do
      let(:no_cov) { true }

      before { allow(Uncov.configuration).to receive_messages(nocov_covered: true, nocov_ignore: false) }

      context 'with simple_cov true' do
        let(:simple_cov) { true }

        it { is_expected.to be_falsy }
      end

      context 'with simple_cov false' do
        let(:simple_cov) { false }

        it { is_expected.to be_truthy }
      end
    end

    context 'with nocov_covered true, nocov_ignore true and nocov true' do
      let(:no_cov) { true }

      before { allow(Uncov.configuration).to receive_messages(nocov_covered: true, nocov_ignore: true) }

      context 'with simple_cov true' do
        let(:simple_cov) { true }

        it { is_expected.to be_falsy }
      end

      context 'with simple_cov false' do
        let(:simple_cov) { false }

        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#nocov_covered?' do
    subject { line.nocov_covered? }

    context 'with nocov_covered true' do
      before { allow(Uncov.configuration).to receive(:nocov_covered).and_return(true) }

      context 'with simple_cov true' do
        let(:simple_cov) { true }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_truthy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'with simple_cov false' do
        let(:simple_cov) { false }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_falsy }
        end
      end

      context 'without simple_cov' do
        let(:simple_cov) { nil }

        context 'with no_cov' do
          let(:no_cov) { true }

          it { is_expected.to be_falsy }
        end

        context 'without no_cov' do
          let(:no_cov) { nil }

          it { is_expected.to be_falsy }
        end
      end
    end
  end

  describe '#trigger?' do
    subject { line.trigger? }

    context 'when does not trigger' do
      let(:no_cov) { true }
      let(:simple_cov) { false }

      it { is_expected.to be_falsy }
    end

    context 'when triggers because of uncov?' do
      let(:no_cov) { nil }
      let(:simple_cov) { false }

      it { is_expected.to be_truthy }
    end

    context 'when triggers because of nocov_covered?' do
      let(:no_cov) { true }
      let(:simple_cov) { true }

      before { allow(Uncov.configuration).to receive(:nocov_covered).and_return(true) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#display?' do
    subject { line.display? }

    context 'when does not display' do
      let(:context) { false }
      let(:no_cov) { true }
      let(:simple_cov) { true }

      it { is_expected.to be_falsy }
    end

    context 'when displays because of context' do
      let(:context) { true }
      let(:no_cov) { true }
      let(:simple_cov) { true }

      it { is_expected.to be_truthy }
    end

    context 'when displays because of trigger' do
      let(:context) { true }
      let(:no_cov) { true }
      let(:simple_cov) { false }

      it { is_expected.to be_truthy }
    end
  end

  describe '#relevant?' do
    subject { line.relevant? }

    context 'when not relevant' do
      let(:no_cov) { true }
      let(:simple_cov) { false }

      it { is_expected.to be_falsy }
    end

    context 'when relevant because of trigger' do
      let(:no_cov) { nil }
      let(:simple_cov) { false }

      it { is_expected.to be_truthy }
    end

    context 'when relevant because of coverage' do
      let(:no_cov) { nil }
      let(:simple_cov) { true }

      it { is_expected.to be_truthy }
    end
  end
end
