require 'fileutils'

require_relative 'module'

module Flint
  # Generate missing resources
  class Generator
    def self.generate_keystore(params,  keystore_name, alias_name, password)
      # Ensure output dir exists
      output_dir = File.join(params[:workspace], "certs")
      FileUtils.mkdir_p output_dir
      output_path = File.join(output_dir, keystore_name)

      full_name = params[:full_name]
      org = params[:orgization]
      org_unit = params[:orgization_unit]
      city_locality = params[:city]
      state_province = params[:state]
      country = params[:country]
      valid_days = 10000 # > 27 years

      cmd = "keytool -genkey -v -keystore %s -alias %s " % [output_path, alias_name]
      cmd << "-keyalg RSA -keysize 2048 -validity %s -keypass %s -storepass %s " % [valid_days, password, password]
      cmd << "-dname \"CN=#{full_name}, OU=#{org_unit}, O=#{org}, L=#{city_locality}, S=#{state_province}, C=#{country}\""

      begin
        output = IO.popen(cmd)
        output.close
      rescue => ex
        raise ex
      end

      return output_path
    end
  end
end
