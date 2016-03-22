require 'fileutils'
require 'sitemap/repository'
require 'sitemap/mapper'
require 'sitemap/base'
require 'sitemap/logger'

module Sitemap
  class Factory
    class SitemapFactoryError < StandardError; end

    def initialize(options = {})
      @env = options[:env] || ENV.fetch("RAILS_ENV", "development")
      @sites = options[:sites].to_s.split(",").map!(&:strip)
      @repository = options.fetch(:repository) { Repository::new(:env => @env, :sites => @sites) }
    end

    def exec
      sitemaps
      index
      propagate
    rescue => e
      Sitemap::logger::error("#{e.message}\n#{e.backtrace.join("\n")}")
      raise SitemapFactoryError, e, e.backtrace
    end

    def files
      @files ||= @sites.reduce([]) do |acc,site|
        Entity::types.each do |type|
          acc << "#{path}/#{type}_#{site}.xml.gz"
        end
        acc
      end
    end

    private

    def mappers_per_site
      mappers = @sites.inject({}) do |acc,site|
        Entity::children.each do |klass|
          mapper = Mapper::new(:site => site, :entities => @repository.entities(klass))
          acc[site] ||= []
          acc[site] << mapper
        end
        acc
      end
      @repository.disconnect
      mappers
    end

    def index
      nodes = files.map { |f| Index::new(:loc => "#{Config::PROTOCOL}://#{@repository.host}/#{Config::BASE_FOLDER}/#{File::basename(f)}") }
      index = Base::new(:name => "#{path}/index.xml",
                        :out => File::new("#{path}/index.xml", "wb"), 
                        :nodes => nodes,
                        :parent => "sitemapindex")
      Sitemap::logger::info("generating index: #{File::basename(index.name)}")
      index.render
      files << index.name
    end

    def sitemaps
      Sitemap::logger::info("going to generate sitemaps for: #{@sites.join(", ")}")
      mappers_per_site.each do |site, mappers|
        fork { create_sitemap(site, mappers) }
      end 
    end

    def create_sitemap(site, mappers)
      mappers.each do |mapper| 
        sitemap = Base::new(:name => "#{mapper.type}_#{site}.xml", 
                            :nodes => mapper.urls)
        Sitemap::logger::info("generating sitemap: #{sitemap.name}.gz")
        sitemap.compress("#{path}/#{sitemap.name}.gz")
      end
    rescue => e
      Sitemap::logger::error("#{e.message}\n#{e.backtrace.join("\n")}")
      raise SitemapFactoryError, e, e.backtrace
    end

    def path
      @path ||= @repository.paths.shift
    end

    def paths
      @repository.paths
    end

    def propagate
      Process.waitall
      paths.each do |p|
        FileUtils::cp files, p
      end
    end
  end
end
