describe Fastlane::Actions::ImagesgoldenrunAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The imagesgoldenrun plugin is working!")

      Fastlane::Actions::ImagesgoldenrunAction.run(nil)
    end
  end
end
