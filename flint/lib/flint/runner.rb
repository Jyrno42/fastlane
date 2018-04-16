require 'fastlane_core/cert_checker'
require 'fastlane_core/print_table'
require_relative 'encrypt'
require_relative 'generator'
require_relative 'git_helper'
require_relative 'module'
require_relative 'table_printer'
require_relative 'utils'

module Flint
  class Runner
    attr_accessor :files_to_commmit

    def run(params)
      self.files_to_commmit = []

      FastlaneCore::PrintTable.print_values(config: params,
                                         hide_keys: [:workspace],
                                             title: "Summary for flint #{Fastlane::VERSION}")

      encrypt = Encrypt.new
      params[:workspace] = GitHelper.clone(params[:git_url],
                                           params[:shallow_clone],
                                           skip_docs: params[:skip_docs],
                                           branch: params[:git_branch],
                                           git_full_name: params[:git_full_name],
                                           git_user_email: params[:git_user_email],
                                           clone_branch_directly: params[:clone_branch_directly],
                                           encrypt: encrypt)

      if params[:app_identifier].kind_of?(Array)
        app_identifiers = params[:app_identifier]
      else
        app_identifiers = params[:app_identifier].to_s.split(/\s*,\s*/).uniq
      end

      # sometimes we get an array with arrays, this is a bug. To unblock people using flint, I suggest we flatten!
      # then in the future address the root cause of https://github.com/fastlane/fastlane/issues/11324
      app_identifiers.flatten!

      # Keystore
      password = encrypt.password(params[:git_url])
      keystore_name = fetch_keystore(params: params, app_identifier: app_identifiers[0], password: password)

      # Done
      if self.files_to_commmit.count > 0 && !params[:readonly]
        message = GitHelper.generate_commit_message(params)
        GitHelper.commit_changes(params[:workspace], message, params[:git_url], params[:git_branch], self.files_to_commmit, encrypt)
      end

      # Print a summary table for each app_identifier
      app_identifiers.each do |app_identifier|
        TablePrinter.print_summary(app_identifier: app_identifier, type: params[:type], keystore_name: keystore_name)
      end

      UI.success("All required keystores are installed 🙌".green)
    ensure
      GitHelper.clear_changes
    end

    def fetch_keystore(params: nil, app_identifier: nil, password: nil)
      cert_type = Flint.cert_type_sym(params[:type])

      app_identifier = app_identifier.gsub! '.', '_'

      alias_name = "%s-%s" % [app_identifier, cert_type.to_s]
      keystore_name = "%s.keystore" % [alias_name]
      target_path = File.join(params[:target_dir], keystore_name)

      certs = Dir[File.join(params[:workspace], "certs", keystore_name)]

      if certs.count == 0
        UI.important("Couldn't find a valid keystore in the git repo for #{cert_type}... creating one for you now")
        UI.crash!("No code signing keystore found and can not create a new one because you enabled `readonly`") if params[:readonly]
        cert_path = Generator.generate_keystore(params, keystore_name, alias_name, password)
        self.files_to_commmit << cert_path

        # install and activate the keystore
        UI.verbose("Installing keystore '#{keystore_name}'")
        Utils.import(cert_path, target_path, keystore_name, alias_name, password)
        Utils.activate(keystore_name, alias_name, password, params[:keystore_properties_path])
      else
        cert_path = certs.last
        UI.message("Installing keystore...")

        if Utils.installed?(cert_path, target_path)
          UI.verbose("Keystore '#{File.basename(cert_path)}' is already installed on this machine")
        else
          UI.verbose("Installing keystore '#{keystore_name}'")
          Utils.import(cert_path, target_path, keystore_name, alias_name, password)
        end

        # Print cert info
        puts("")
        puts(Utils.get_keystore_info(cert_path, password))
        puts("")

        # Activate the cert
        Utils.activate(keystore_name, alias_name, password, params[:keystore_properties_path])
      end

      return File.basename(cert_path).gsub(".keystore", "")
    end
  end
end
