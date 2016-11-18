require 'logger'
require 'logstash-logger'

module TaxTribunal
  class Downloader < Sinatra::Base
    # This is exceptionally difficult to stub and any issues will get bubbled
    # up to the application anyway.
    # :nocov:
    configure :production, :development do
      enable :logging
      use Rack::CommonLogger, LogStashLogger.new(type: :stdout)
    end
    # :nocov:

    configure do
      enable :sessions
      set :raise_errors, true
      set :show_exceptions, false
      set :views, "#{settings.root}/../../views"
      set :public_folder, "#{settings.root}/../../public"
    end
  end
end