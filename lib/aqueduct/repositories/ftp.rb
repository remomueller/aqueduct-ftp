require 'aqueduct'
require 'net/ftp'

# The default FTP Wrapper will download the file(s) from the remote ftp server and place them in a local
# cache in <Rails.root>/tmp/symbolic/source_<id>/<remote_path>/<file_name>.  This cache essentially makes
# the file service act as if it's a local mounted repository. (And should only be used to get up and
# running quickly.)

# NOTE!
# A Better FTP wrapper would generate a dynamic login and password on the FTP server with a link to that
# server with the appropriate files readily available in a folder so the user can download directly from
# the FTP without having to have the files first downloaded to the server hosting the Rails Application.
# A better FTP wrapper could be implemented as a new wrapper.

module Aqueduct
  module Repositories
    class Ftp
      include Aqueduct::Repository

      def count_files(file_locators, file_type)
        error = ''
        file_paths = []
        url_paths = []
        begin
          ftp = Net::FTP.new #(@source.file_server_host, @source.file_server_login, @source.file_server_password)
          ftp.connect(@source.file_server_host, 21)
          ftp.login(@source.file_server_login, @source.file_server_password)

          ftp.chdir(@source.file_server_path)

          file_locators.each do |file_locator|
            file_locator = file_locator.to_s.gsub(/[\/*]/, '') # Don't allow wild cards or subfolders
            file_type = file_type.to_s.gsub(/[\/*]/, '')       # Don't allow wild cards or subfolders
            file_name = file_locator + file_type
            file_path = File.join(Rails.root, 'tmp', 'symbolic', "source_#{@source.id}", @source.file_server_path)

            if File.exists?(File.join(file_path, file_name))
              # Do nothing
              # Rails.logger.debug "File already exists"
            else
              begin
                # Rails.logger.debug "Retrieving #{file_name} from FTP"
                FileUtils.mkpath(file_path)
                ftp.getbinaryfile(file_name, File.join(file_path, file_name))
              rescue
                # Rails.logger.debug "           #{file_name} not found!"
                File.delete(File.join(file_path, file_name)) if File.exists?(File.join(file_path, file_name))
                file_name = nil
              end
            end

            file_paths << File.join(file_path, file_name) unless file_name.blank?
            url_paths << SITE_URL + "/sources/#{@source.id}/download_file?file_locator=#{file_locator}&file_type=#{file_type}&fn=#{file_name.split('/').last}" unless file_name.blank?

          end
        rescue => e
          error = e.to_s
        ensure
          begin
            ftp.close
          rescue => e
            # We don't care.
          end
        end
        { result: url_paths.size, error: error, file_paths: file_paths, urls: url_paths }
      end

      def get_file(file_locator, file_type)
        result_hash = count_files([file_locator], file_type)
        { file_path: result_hash[:file_paths].first.to_s, error: result_hash[:error] }
      end

      def has_repository?
        { result: true, error: '' }
      end

      def file_server_available?
        result = false
        error = ''
        begin
          ftp = Net::FTP.new
          ftp.connect(@source.file_server_host, 21)
          ftp.login(@source.file_server_login, @source.file_server_password)
          result = true
        rescue => e
          error = e.to_s
        ensure
          begin
            ftp.close
          rescue => e
            # We don't care.
          end
        end
        { result: result, error: error }
      end
    end
  end
end