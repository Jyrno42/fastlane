require 'digest'
require 'fileutils'
require 'openssl'
require_relative 'module'

module Flint
  class Utils
    def self.import(item_path, target_path, keystore_name, alias_name, password)
      FileUtils.copy_file(item_path, target_path)
    end

    def self.activate(keystore_name, alias_name, password, keystore_properties_path)
      template = File.read("#{Flint::ROOT}/lib/assets/KeystorePropertiesTemplate")
      template.gsub!("[[STORE_FILE]]", keystore_name)
      template.gsub!("[[KEY_ALIAS]]", alias_name)
      template.gsub!("[[PASSWORD]]", password)
      File.write(keystore_properties_path, template)

      # We could test that the required lines are added to build.gradle
    end

    def self.installed?(item_path, target_path)
      if File.exist?(target_path)
        installed_digest = Digest::MD5.hexdigest File.read target_path
        item_digest = Digest::MD5.hexdigest File.read item_path

        return installed_digest == item_digest
      end

      return false
    end

    def self.get_keystore_info(item_path, password)
      cmd = 
      begin
        output = IO.popen("keytool -list -v -keystore '#{item_path}' -storepass '#{password}'")
        lines = output.readlines
        output.close
      rescue => ex
        raise ex
      end

      return lines
    end
  end
end
