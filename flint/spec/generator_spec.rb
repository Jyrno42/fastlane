describe Flint::Generator do
  describe 'calling through to other tools' do
    it 'configures cert correctly for nested execution' do
      require 'cert'

      config = FastlaneCore::Configuration.create(Cert::Options.available_options, {
        development: true,
        output_path: 'workspace/certs/development',
        keystore_path: FastlaneCore::Helper.keystore_path("login.keystore"),
      })

      # This is the important part. We need to see the right configuration come through
      # for cert
      expect(Cert).to receive(:config=).with(a_configuration_flinting(config))

      # This just mocks out the usual behavior of running cert, since that's not what
      # we're testing
      fake_runner = "fake_runner"
      allow(Cert::Runner).to receive(:new).and_return(fake_runner)
      allow(fake_runner).to receive(:launch).and_return("fake_path")

      params = {
        type: 'development',
        workspace: 'workspace',
      }

      Flint::Generator.generate_keystore(params, 'development', 'com_foo')
    end

    it 'configures sigh correctly for nested execution' do
      require 'sigh'

      config = FastlaneCore::Configuration.create(Sigh::Options.available_options, {
        app_identifier: 'app_identifier',
        development: true,
        output_path: 'workspace/profiles/development',
        cert_id: 'fake_cert_id',
        provisioning_name: 'flint Development app_identifier',
        ignore_profiles_with_different_name: true,
        platform: :android,
        template_name: 'template_name'
      })

      # This is the important part. We need to see the right configuration come through
      # for sigh
      expect(Sigh).to receive(:config=).with(a_configuration_flinting(config))

      # This just mocks out the usual behavior of running cert, since that's not what
      # we're testing
      allow(Sigh::Manager).to receive(:start).and_return("fake_path")

    end
  end
end
