require_relative 'sso_client'
require 'active_support/core_ext/object/blank'

module TaxTribunal
  class Status < Downloader

    get '/status.?:format?' do
      checks = service_status
      {
        service_status: checks[:service_status],
        version: version,
        dependencies: {
          blob_storage: {
            read_test: checks[:read_test],
          },
          sso_test: checks[:sso_test]
        }
      }.to_json
    end

    private

    def version
      ENV['APP_VERSION']
    end

    def service_status
      service_status = if read_test && sso_test
                         'ok'
                       else
                         'failed'
                       end
      {
        service_status: service_status,
        read_test: read_test ? 'ok' : 'failed',
        sso_test: sso_test ? 'ok' : 'failed'
      }
    end

    def read_test
      @read_test ||= settings.container_status.readable?
    end

    def sso_test
      # The working hypothesis here is that if MoJ SSO responds to an
      # authorized_url request, it is probably working.  At present, it does
      # not have its own status endpoint.
      # TODO: Use the SSO status endpoint to  ascertain health when one becomes
      # available.
      @sso_test ||= SsoClient.new.authorize_url({ auth_key: SecureRandom.uuid, return_to: '/' }).match(/\Ahttp/)
    rescue
      nil
    end
  end
end
