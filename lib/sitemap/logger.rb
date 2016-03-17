require 'logger'

module Sitemap
  extend self

  attr_writer :logger

  LOGGER_FILE = File.expand_path("../../../log/sitemap.log", __FILE__)

  def logger(file: LOGGER_FILE, rotation: "weekly", level: Logger::INFO)
    @logger ||= Logger::new(file, rotation).tap do |logger|
      logger.level = level
    end
  end
end
