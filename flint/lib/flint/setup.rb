require_relative 'module'

module Flint
  class Setup
    def run(path)
      template = File.read("#{Flint::ROOT}/lib/assets/FlintfileTemplate")

      UI.important("Please create a new, private git repository")
      UI.important("to store the keystores there")
      url = UI.input("URL of the Git Repo: ")

      template.gsub!("[[GIT_URL]]", url)
      File.write(path, template)
      UI.success("Successfully created '#{path}'. You can open the file using a code editor.")

      UI.important("You can now run `fastlane flint development` and `fastlane flint release`")
      UI.message("On the first run for each environment it will create the keystore for you.")
      UI.message("From then on, it will automatically import the existing keystores.")
      UI.message("For more information visit https://docs.fastlane.tools/actions/flint/")
    end
  end
end
