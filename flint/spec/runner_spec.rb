describe Flint do
  describe Flint::Runner do
    let(:keystore) { 'login.keystore' }

    before do
      allow(ENV).to receive(:[]).and_call_original
    end

    it "creates a new profile and certificate if it doesn't exist yet" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "playstore",
        git_url: git_url,
        shallow_clone: true
      }

      config = FastlaneCore::Configuration.create(Flint::Options.available_options, values)
      repo_dir = Dir.mktmpdir
      cert_path = File.join(repo_dir, "something.cer")
      profile_path = "./flint/spec/fixtures/test.mobileprovision"
      keystore_path = FastlaneCore::Helper.keystore_path("login.keystore") # can be .keystore or .keystore-db
      destination = File.expand_path("~/Library/MobileDevice/Provisioning Profiles/98264c6b-5151-4349-8d0f-66691e48ae35.mobileprovision")

      expect(Flint::GitHelper).to receive(:clone).with(git_url, true, skip_docs: false, branch: "master", git_full_name: nil, git_user_email: nil, clone_branch_directly: false).and_return(repo_dir)
      expect(Flint::Generator).to receive(:generate_keystore).with(config, :distribution).and_return(cert_path)
      expect(FastlaneCore::ProvisioningProfile).to receive(:install).with(profile_path, keystore_path).and_return(destination)
      expect(Flint::GitHelper).to receive(:commit_changes).with(
        repo_dir,
        "[fastlane] Updated playstore and platform android",
        git_url,
        "master",
        [
          File.join(repo_dir, "something.cer"),
          File.join(repo_dir, "something.p12"), # this is important, as a cert consists out of 2 files
          "./flint/spec/fixtures/test.mobileprovision"
        ]
      )

      spaceship = "spaceship"
      expect(Flint::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Flint::Runner.new.run(config)

      expect(ENV[Flint::Utils.environment_variable_name(app_identifier: "tools.fastlane.app",
                                                        type: "playstore")]).to eql('98264c6b-5151-4349-8d0f-66691e48ae35')
      expect(ENV[Flint::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app",
                                                                     type: "playstore")]).to eql('tools.fastlane.app playstore')
      profile_path = File.expand_path('~/Library/MobileDevice/Provisioning Profiles/98264c6b-5151-4349-8d0f-66691e48ae35.mobileprovision')
      expect(ENV[Flint::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app",
                                                                     type: "playstore")]).to eql(profile_path)
    end

    it "uses existing certificates and profiles if they exist" do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "playstore",
        git_url: git_url
      }

      config = FastlaneCore::Configuration.create(Flint::Options.available_options, values)
      repo_dir = "./flint/spec/fixtures/existing"
      cert_path = "./flint/spec/fixtures/existing/certs/distribution/E7P4EE896K.cer"
      key_path = "./flint/spec/fixtures/existing/certs/distribution/E7P4EE896K.p12"

      expect(Flint::GitHelper).to receive(:clone).with(git_url, false, skip_docs: false, branch: "master", git_full_name: nil, git_user_email: nil, clone_branch_directly: false).and_return(repo_dir)
      expect(Flint::Utils).to receive(:import).with(key_path, keystore, password: nil).and_return(nil)
      expect(Flint::GitHelper).to_not(receive(:commit_changes))

      # To also install the certificate, fake that
      expect(FastlaneCore::CertChecker).to receive(:installed?).with(cert_path).and_return(false)
      expect(Flint::Utils).to receive(:import).with(cert_path, keystore, password: nil).and_return(nil)

      spaceship = "spaceship"
      expect(Flint::SpaceshipEnsure).to receive(:new).and_return(spaceship)
      expect(spaceship).to receive(:certificate_exists).and_return(true)
      expect(spaceship).to receive(:profile_exists).and_return(true)
      expect(spaceship).to receive(:bundle_identifier_exists).and_return(true)

      Flint::Runner.new.run(config)

      expect(ENV[Flint::Utils.environment_variable_name(app_identifier: "tools.fastlane.app",
                                                        type: "playstore")]).to eql('736590c3-dfe8-4c25-b2eb-2404b8e65fb8')
      expect(ENV[Flint::Utils.environment_variable_name_profile_name(app_identifier: "tools.fastlane.app",
                                                                     type: "playstore")]).to eql('flint PlayStore tools.fastlane.app 1449198835')
      profile_path = File.expand_path('~/Library/MobileDevice/Provisioning Profiles/736590c3-dfe8-4c25-b2eb-2404b8e65fb8.mobileprovision')
      expect(ENV[Flint::Utils.environment_variable_name_profile_path(app_identifier: "tools.fastlane.app",
                                                                     type: "playstore")]).to eql(profile_path)
    end
  end
end
