require 'fileutils'
require 'sitemap/repository'
require 'sitemap/mapper'
require 'sitemap/base'
require 'sitemap/logger'

module Sitemap
  class Factory
    TYPES = %w[categories sorts styles stores].freeze

    class SitemapFactoryError < StandardError; end

    def initialize(options = {})
      @env = options[:env] || ENV.fetch("RAILS_ENV", "development")
      @sites = options[:sites].to_s.split(",").map!(&:strip)
      @repository = options.fetch(:repository) { Repository::new(:env => @env, :sites => @sites) }
    end

    def exec
      sitemaps
      homes
      index
      propagate
    rescue => e
      Sitemap::logger::error("#{e.message}\n#{e.backtrace.join("\n")}")
      raise SitemapFactoryError, e, e.backtrace
    end

    def files
      @files ||= @sites.reduce([]) do |acc,site|
        TYPES.each do |type|
          acc << "#{path}/#{type}_#{site}.xml.gz"
        end
        acc
      end
    end

    private

    def mappers
      mappers = @sites.inject({}) do |acc,site|
        acc[site] = Mapper::new(:site => site, 
                                :categories => @repository.categories, 
                                :sorts => @repository.sorts,
                                :styles => @repository.styles,
                                :stores => @repository.stores)
        acc
      end
      @repository.disconnect
      mappers
    end

    def index
      nodes = files.map { |f| Index::new(:loc => "#{PROTOCOL}://#{@repository.host}/#{BASE_FOLDER}/#{File::basename(f)}") }
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
      mappers.each do |site, mapper|
        fork { create_sitemap(site, mapper) }
      end 
    end

    def create_sitemap(site, mapper)
      TYPES.each do |type| 
        sitemap = Base::new(:name => "#{type}_#{site}.xml", :nodes => mapper.send("#{type}_urls"))
        Sitemap::logger::info("generating sitemap: #{sitemap.name}.gz")
        sitemap.compress("#{path}/#{sitemap.name}.gz")
      end
    rescue => e
      Sitemap::logger::error("#{e.message}\n#{e.backtrace.join("\n")}")
      raise SitemapFactoryError, e, e.backtrace
    end

    def homes
      nodes = Mapper::homes_urls(@repository.host, @sites)
      sitemap = Base::new(:name => "homes.xml", :nodes => nodes)
      Sitemap::logger::info("generating sitemap: #{sitemap.name}.gz")
      gz = "#{path}/#{sitemap.name}.gz"
      sitemap.compress(gz)
      files << gz
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
