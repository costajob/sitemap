require 'fileutils'
require 'sitemap/repository'
require 'sitemap/entities'
require 'sitemap/mapper'
require 'sitemap/base'
require 'sitemap/logger'

module Sitemap
  class Factory
    class SitemapFactoryError < StandardError; end

    attr_reader :files

    def initialize(options = {})
      @env = options[:env] || ENV.fetch("RAILS_ENV", "development")
      @sites = options[:sites].to_s.split(",").map!(&:strip)
      @repository = options.fetch(:repository) { Repository::new(:sites => @sites) }
      @hreflang = options[:hreflang]
      @files = []
    end

    def exec
      sitemaps
      index
      propagate
    rescue => e
      Sitemap::logger::error("#{e.message}\n#{e.backtrace.join("\n")}")
      raise SitemapFactoryError, e, e.backtrace
    end

    private

    def mappers_per_site
      data = @sites.inject({}) do |acc,site|
        Entity::children.each do |klass|
          mapper = Mapper::new(:site => site, 
                               :entities => @repository.entities(klass),
                               :hreflang => !!@hreflang)
          acc[site] ||= []
          acc[site] << mapper
        end
        acc
      end
      @repository.disconnect
      data
    end

    def index
      index = Base::new(:name => "#{path}/index.xml",
                        :out => File::new("#{path}/index.xml", "wb"), 
                        :nodes => index_nodes,
                        :parent => "sitemapindex")
      Sitemap::logger::info("generating index: #{File::basename(index.name)}")
      index.render
      @files << index.name
    end

    def index_nodes
      @files.map do |f| 
        Index::new(:loc => "#{Config::PROTOCOL}://#{@repository.host}/#{Config::BASE_FOLDER}/#{File::basename(f)}")
      end
    end

    def sitemaps
      Sitemap::logger::info("going to generate sitemaps for: #{@sites.join(", ")}")
      return sitemaps_no_fork if Config::MAX_PROCS <= 1
      mappers_per_site.each_slice(slice_size) do |slice|
        fork do
          slice.each do |site, mappers|
            create_sitemap(site, mappers)
          end
        end
      end
      Process.waitall
    end

    def sitemaps_no_fork
      mappers_per_site.each do |site, mappers|
        create_sitemap(site, mappers)
      end
    end

    def slice_size
      @sites.size / Config::MAX_PROCS
    end

    def create_sitemap(site, mappers)
      mappers.each do |mapper| 
        sitemap = Base::new(:name => "#{mapper.type}_#{site}.xml", 
                            :nodes => mapper.urls)
        Sitemap::logger::info("generating sitemap: #{sitemap.name}.gz")
        gz = "#{path}/#{sitemap.name}.gz"
        sitemap.compress(gz)
        @files << gz
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
      paths.each do |p|
        FileUtils::cp(@files, p)
      end
    end
  end
end
