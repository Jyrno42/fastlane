require 'commander'

require 'fastlane_core/configuration/configuration'
require_relative 'module'
require_relative 'nuke'
require_relative 'git_helper'
require_relative 'change_password'
require_relative 'setup'
require_relative 'runner'
require_relative 'options'
require_relative 'encrypt'

HighLine.track_eof = false

module Flint
  class CommandsGenerator
    include Commander::Methods

    def self.start
      self.new.run
    end

    def run
      program :name, 'flint'
      program :version, Fastlane::VERSION
      program :description, Flint::DESCRIPTION
      program :help, 'Author', 'Jyrno Ader <jyrno@thorgate.eu>'
      program :help, 'Website', 'https://fastlane.tools'
      program :help, 'Documentation', 'https://docs.fastlane.tools/actions/flint/'
      program :help_formatter, :compact

      global_option('--verbose') { FastlaneCore::Globals.verbose = true }

      command :run do |c|
        c.syntax = 'fastlane flint'
        c.description = Flint::DESCRIPTION

        FastlaneCore::CommanderGenerator.new.generate(Flint::Options.available_options, command: c)

        c.action do |args, options|
          if args.count > 0
            FastlaneCore::UI.user_error!("Please run `fastlane flint [type]`, allowed values: development or release")
          end

          params = FastlaneCore::Configuration.create(Flint::Options.available_options, options.__hash__)
          params.load_configuration_file("Flintfile")
          Flint::Runner.new.run(params)
        end
      end

      Flint.environments.each do |type|
        command type do |c|
          c.syntax = "fastlane flint #{type}"
          c.description = "Run flint for a #{type} profile"

          FastlaneCore::CommanderGenerator.new.generate(Flint::Options.available_options, command: c)

          c.action do |args, options|
            params = FastlaneCore::Configuration.create(Flint::Options.available_options, options.__hash__)
            params.load_configuration_file("Flintfile") # this has to be done *before* overwriting the value
            params[:type] = type.to_s
            Flint::Runner.new.run(params)
          end
        end
      end

      command :init do |c|
        c.syntax = 'fastlane flint init'
        c.description = 'Create the Flintfile for you'
        c.action do |args, options|
          containing = FastlaneCore::Helper.fastlane_enabled_folder_path
          path = File.join(containing, "Flintfile")

          if File.exist?(path)
            FastlaneCore::UI.user_error!("You already have a Flintfile in this directory (#{path})")
            return 0
          end

          Flint::Setup.new.run(path)
        end
      end

      command :change_password do |c|
        c.syntax = 'fastlane flint change_password'
        c.description = 'Re-encrypt all files with a different password'

        FastlaneCore::CommanderGenerator.new.generate(Flint::Options.available_options, command: c)

        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Flint::Options.available_options, options.__hash__)
          params.load_configuration_file("Flintfile")

          Flint::ChangePassword.update(params: params)
          UI.success("Successfully changed the password. Make sure to update the password on all your clients and servers")
        end
      end

      command :decrypt do |c|
        c.syntax = "fastlane flint decrypt"
        c.description = "Decrypts the repository and keeps it on the filesystem"

        FastlaneCore::CommanderGenerator.new.generate(Flint::Options.available_options, command: c)

        c.action do |args, options|
          params = FastlaneCore::Configuration.create(Flint::Options.available_options, options.__hash__)
          params.load_configuration_file("Flintfile")
          encrypt = Encrypt.new
          decrypted_repo = Flint::GitHelper.clone(params[:git_url],
                                                  params[:shallow_clone],
                                                  branch: params[:git_branch],
                                                  clone_branch_directly: params[:clone_branch_directly], 
                                                  encrypt: encrypt)
          UI.success("Repo is at: '#{decrypted_repo}'")
        end
      end

      command "nuke" do |c|
        # We have this empty command here, since otherwise the normal `flint` command will be executed
        c.syntax = "fastlane flint nuke"
        c.description = "Delete all keystores"
        c.action do |args, options|
          FastlaneCore::UI.user_error!("Please run `fastlane flint nuke [type], allowed values: development and release.")
        end
      end

      ["development", "release"].each do |type|
        command "nuke #{type}" do |c|
          c.syntax = "fastlane flint nuke #{type}"
          c.description = "Delete all keystores of the type #{type}"

          FastlaneCore::CommanderGenerator.new.generate(Flint::Options.available_options, command: c)

          c.action do |args, options|
            params = FastlaneCore::Configuration.create(Flint::Options.available_options, options.__hash__)
            params.load_configuration_file("Flintfile")
            Flint::Nuke.new.run(params, type: type.to_s)
          end
        end
      end

      default_command(:run)

      run!
    end
  end
end
