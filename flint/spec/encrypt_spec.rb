describe Flint do
  describe Flint::Encrypt do
    before do
      @directory = Dir.mktmpdir
      @content = "#{Time.now.to_i} so random"
      @full_path = File.join(@directory, "randomFile.mobileprovision")
      File.write(@full_path, @content)
      @git_url = "https://github.com/fastlane/fastlane/tree/master/so_random"
      allow(Dir).to receive(:mktmpdir).and_return(@directory)
      ENV["FLINT_PASSWORD"] = '2"QAHg@v(Qp{=*n^'

      @e = Flint::Encrypt.new
    end

    it "encrypt" do
      @e = Flint::Encrypt.new
      @e.encrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to_not(eq(@content))

      @e.decrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to eq(@content)
    end

    it "raises an exception if invalid password is passed" do
      @e.encrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to_not(eq(@content))

      ENV["FLINT_PASSWORD"] = "invalid"
      expect do
        @e.decrypt_repo(path: @directory, git_url: @git_url)
      end.to raise_error("Invalid password passed via 'FLINT_PASSWORD'")
    end

    it "raises an exception if no password is supplied" do
      ENV["FLINT_PASSWORD"] = ""
      expect do
        @e.encrypt_repo(path: @directory, git_url: @git_url)
      end.to raise_error("No password supplied")
    end
  end
end
