require 'yaml'
require 'erb'

module Sitemap
  module Config
    extend self

    BASE_FOLDER = "sitemap".freeze
    DB_ENV = ENV.fetch("RAILS_ENV") { "development" }.freeze
    PROTOCOL = "http".freeze
    MAX_PROCS = ENV.fetch("MAX_PROCS") { 3 }

    class DBConfigError < ArgumentError; end

    def hreflang
      @hreflang ||= YAML::load_file(File.expand_path("../../../config/hreflang.yml", __FILE__))
    end

    def database
      @database ||= YAML.load(ERB.new(File.read(File.expand_path("../../../config/database.yml", __FILE__))).result)
    end

    def connection_params
      @connection_params ||= database.fetch(DB_ENV) { fail DBConfigError, "missing connection for #{DB_ENV}" }
    end
  end
end
