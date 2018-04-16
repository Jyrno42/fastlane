require 'fastlane_core/configuration/config_item'
require_relative 'module'

module Flint
  class Options
    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :git_url,
                                     env_name: "FLINT_GIT_URL",
                                     description: "URL to the git repo containing all the keystores",
                                     optional: false,
                                     short_option: "-r"),
        FastlaneCore::ConfigItem.new(key: :full_name,
                                    env_name: "FLINT_FULL_NAME",
                                    description: "Full name of the owner of the keystores",
                                    optional: false,
                                    is_string: true,
                                    short_option: "-n"),
        FastlaneCore::ConfigItem.new(key: :orgization,
                                    env_name: "FLINT_ORGANIZATION",
                                    description: "Organization of the owner of the keystores",
                                    is_string: true,
                                    short_option: "-o",
                                    default_value: ""),
        FastlaneCore::ConfigItem.new(key: :orgization_unit,
                                    env_name: "FLINT_ORGANIZATION_UNIT",
                                    description: "Organization unit of the owner of the keystores",
                                    is_string: true,
                                    short_option: "-u",
                                    default_value: ""),
        FastlaneCore::ConfigItem.new(key: :city,
                                    env_name: "FLINT_CITY",
                                    description: "City of the owner of the keystores",
                                    optional: false,
                                    is_string: true,
                                    short_option: "-c"),
        FastlaneCore::ConfigItem.new(key: :state,
                                    env_name: "FLINT_STATE",
                                    description: "State of the owner of the keystores",
                                    optional: false,
                                    is_string: true,
                                    short_option: "-s"),
        FastlaneCore::ConfigItem.new(key: :country,
                                    env_name: "FLINT_COUNTRY",
                                    description: "Country of the owner of the keystores (2 letters, e.g EE)",
                                    optional: false,
                                    is_string: true,
                                    short_option: "-x"),
        FastlaneCore::ConfigItem.new(key: :git_branch,
                                     env_name: "FLINT_GIT_BRANCH",
                                     description: "Specific git branch to use",
                                     default_value: 'master'),
        FastlaneCore::ConfigItem.new(key: :type,
                                     env_name: "FLINT_TYPE",
                                     description: "Define the profile type, can be #{Flint.environments.join(', ')}",
                                     is_string: true,
                                     short_option: "-y",
                                     default_value: 'development',
                                     verify_block: proc do |value|
                                       unless Flint.environments.include?(value)
                                         UI.user_error!("Unsupported environment #{value}, must be in #{Flint.environments.join(', ')}")
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "FLINT_APP_IDENTIFIER",
                                     description: "The bundle identifier(s) of your app (comma-separated)",
                                     is_string: false,
                                     type: Array, # we actually allow String and Array here
                                     skip_type_validation: true,
                                     code_gen_sensitive: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                     default_value_dynamic: true),
        FastlaneCore::ConfigItem.new(key: :readonly,
                                     env_name: "FLINT_READONLY",
                                     description: "Only fetch existing keystores, don't generate new ones",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :git_full_name,
                                     env_name: "FLINT_GIT_FULL_NAME",
                                     description: "git user full name to commit",
                                     optional: true,
                                     default_value: nil),
        FastlaneCore::ConfigItem.new(key: :git_user_email,
                                     env_name: "FLINT_GIT_USER_EMAIL",
                                     description: "git user email to commit",
                                     optional: true,
                                     default_value: nil),
        FastlaneCore::ConfigItem.new(key: :verbose,
                                     env_name: "FLINT_VERBOSE",
                                     description: "Print out extra information and all commands",
                                     is_string: false,
                                     default_value: false,
                                     verify_block: proc do |value|
                                       FastlaneCore::Globals.verbose = true if value
                                     end),
        FastlaneCore::ConfigItem.new(key: :keystore_properties_path,
                                     env_name: "FLINT_KEYSTORE_PROPERTIES_PATH",
                                     description: "Set target path for keystore.properties fie",
                                     default_value: "./keystore.properties"),
        FastlaneCore::ConfigItem.new(key: :target_dir,
                                     env_name: "FLINT_TARGET_DIR",
                                     description: "Set target dir for flint keystores",
                                     default_value: "./app/"),
        FastlaneCore::ConfigItem.new(key: :skip_confirmation,
                                     env_name: "FLINT_SKIP_CONFIRMATION",
                                     description: "Disables confirmation prompts during nuke, answering them with yes",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :shallow_clone,
                                     env_name: "FLINT_SHALLOW_CLONE",
                                     description: "Make a shallow clone of the repository (truncate the history to 1 revision)",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :clone_branch_directly,
                                     env_name: "FLINT_CLONE_BRANCH_DIRECTLY",
                                     description: "Clone just the branch specified, instead of the whole repo. This requires that the branch already exists. Otherwise the command will fail",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     description: nil,
                                     verify_block: proc do |value|
                                       unless Helper.test?
                                         if value.start_with?("/var/folders") || value.include?("tmp/") || value.include?("temp/")
                                           # that's fine
                                         else
                                           UI.user_error!("Specify the `git_url` instead of the `path`")
                                         end
                                       end
                                     end,
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_docs,
                                     env_name: "FLINT_SKIP_DOCS",
                                     description: "Skip generation of a README.md for the created git repository",
                                     is_string: false,
                                     default_value: false)
      ]
    end
  end
end
