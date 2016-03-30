require 'logger'

module Sitemap
  extend self

  attr_writer :logger

  LOGGER_FILE = File.expand_path("../../../log/sitemap.log", __FILE__)

  def logger(options = {})
    file = options.fetch(:file) { LOGGER_FILE }
    rotation = options.fetch(:rotation) { "weekly" }
    level = options.fetch(:level) { Logger::INFO }
    @logger ||= Logger::new(file, rotation).tap do |logger|
      logger.level = level
    end
  end
end
