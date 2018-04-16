module Fastlane
  module Actions
    class FlintAction < Action
      def self.run(params)
        require 'flint'

        params.load_configuration_file("Flintfile")
        Flint::Runner.new.run(params)

        define_profile_type(params)
      end

      def self.define_profile_type(params)
        profile_type = "app-store"
        profile_type = "ad-hoc" if params[:type] == 'adhoc'
        profile_type = "development" if params[:type] == 'development'
        profile_type = "enterprise" if params[:type] == 'enterprise'

        UI.message("Setting Provisioning Profile type to '#{profile_type}'")

        Actions.lane_context[SharedValues::SIGH_PROFILE_TYPE] = profile_type
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Easily sync your certificates and profiles across your team (via _flint_)"
      end

      def self.details
        "More information: https://docs.fastlane.tools/actions/flint/"
      end

      def self.available_options
        require 'flint'
        Flint::Options.available_options
      end

      def self.output
        []
      end

      def self.return_value
      end

      def self.authors
        ["Jyrno42"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'flint(type: "playstore", app_identifier: "tools.fastlane.app")',
          'flint(type: "development", readonly: true)',
          'flint(app_identifier: ["tools.fastlane.app", "tools.fastlane.sleepy"])'
        ]
      end

      def self.category
        :code_signing
      end
    end
  end
end
