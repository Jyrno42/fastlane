describe Flint do
  describe Flint::Utils do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:backticks).with('security -h | grep set-key-partition-list', print: false).and_return('    set-key-partition-list               Set the partition list of a key.')
    end

    describe 'import' do
      it 'finds a normal keystore name relative to ~/Library/Keystores' do
        expected_command = "security import item.path -k '#{Dir.home}/Library/Keystores/login.keystore' -P '' -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        allowed_command = "security set-key-partition-list -S apple-tool:,apple: -k '' #{Dir.home}/Library/Keystores/login.keystore &> /dev/null"

        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keystores/login.keystore").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        allow(FastlaneCore::Helper).to receive(:backticks).with(allowed_command, print: FastlaneCore::Globals.verbose?)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: FastlaneCore::Globals.verbose?)

        Flint::Utils.import('item.path', 'login.keystore')
      end

      it 'treats a keystore name it cannot find in ~/Library/Keystores as the full keystore path' do
        tmp_path = Dir.mktmpdir
        keystore = "#{tmp_path}/my/special.keystore"
        expected_command = "security import item.path -k '#{keystore}' -P '' -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        allowed_command = "security set-key-partition-list -S apple-tool:,apple: -k '' #{keystore} &> /dev/null"

        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with(keystore).and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with('item.path').and_return(true)

        allow(FastlaneCore::Helper).to receive(:backticks).with(allowed_command, print: FastlaneCore::Globals.verbose?)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: FastlaneCore::Globals.verbose?)

        Flint::Utils.import('item.path', keystore)
      end

      it 'shows a user error if the keystore path cannot be resolved' do
        allow(File).to receive(:exist?).and_return(false)

        expect do
          Flint::Utils.import('item.path', '/my/special.keystore')
        end.to raise_error(/Could not locate the provided keystore/)
      end

      it "tries to find the macOS Sierra keystore too" do
        expected_command = "security import item.path -k '#{Dir.home}/Library/Keystores/login.keystore-db' -P '' -T /usr/bin/codesign -T /usr/bin/security &> /dev/null"

        # this command is also sent on macOS Sierra and we need to allow it or else the test will fail
        allowed_command = "security set-key-partition-list -S apple-tool:,apple: -k '' #{Dir.home}/Library/Keystores/login.keystore-db &> /dev/null"

        allow(File).to receive(:file?).and_return(false)
        expect(File).to receive(:file?).with("#{Dir.home}/Library/Keystore/login.keystore-db").and_return(true)
        allow(File).to receive(:exist?).and_return(false)
        expect(File).to receive(:exist?).with("item.path").and_return(true)

        allow(FastlaneCore::Helper).to receive(:backticks).with(allowed_command, print: FastlaneCore::Globals.verbose?)
        expect(FastlaneCore::Helper).to receive(:backticks).with(expected_command, print: FastlaneCore::Globals.verbose?)

        Flint::Utils.import('item.path', "login.keystore")
      end
    end

    describe "fill_environment" do
      it "#environment_variable_name uses the correct env variable" do
        result = Flint::Utils.environment_variable_name(app_identifier: "tools.fastlane.app", type: "playstore")
        expect(result).to eq("sigh_tools.fastlane.app_playstore")
      end

      it "#environment_variable_name_profile_name uses the correct env variable" do
        result = Flint::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app", type: "playstore")
        expect(result).to eq("sigh_tools.fastlane.app_playstore_profile-name")
      end

      it "#environment_variable_name_profile_path uses the correct env variable" do
        result = Flint::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app", type: "playstore")
        expect(result).to eq("sigh_tools.fastlane.app_playstore_profile-path")
      end

      it "pre-fills the environment" do
        my_key = "my_test_key"
        uuid = "my_uuid"

        result = Flint::Utils.fill_environment(my_key, uuid)
        expect(result).to eq(uuid)

        item = ENV.find { |k, v| v == uuid }
        expect(item[0]).to eq(my_key)
        expect(item[1]).to eq(uuid)
      end
    end
  end
end
