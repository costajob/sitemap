require 'sitemap/entities'
require 'sitemap/nodes'

module Sitemap
  class Mapper
    def self.homes_urls(host, sites)
      sites.map do |site|
        home = Sitemap::Home::new(:host => host, :site => site)
        links = home.siblings(sites).map! { |entity| Link::new(:site => entity.site, :loc => entity.loc) }
        URL::new(:loc => home.loc, :links => links)
      end
    end

    def initialize(options = {})
      @site = options.fetch(:site) { fail ArgumentError, "missing site abbreviation" }
      @categories = options.fetch(:categories) { [] }
      @sorts = options.fetch(:sorts) { [] }
      @styles = options.fetch(:styles) { [] }
      @stores = options.fetch(:stores) { [] }
    end

    def categories_urls
      fetch_urls(@categories)
    end

    def sorts_urls
      fetch_urls(@sorts)
    end

    def styles_urls
      fetch_urls(@styles)
    end

    def stores_urls
      fetch_urls(@stores)
    end

    private

    def fetch_urls(entities)
      filter_by_site(entities).map! do |entity|
        URL::new(:loc => entity.loc, :links => links(entity, entities))
      end
    end

    def filter_by_site(entities)
      entities.select { |entity| entity.site == @site }
    end

    def links(entity, entities)
      entity.siblings(entities).map! { |entity| Link::new(:site => entity.site, :loc => entity.loc) }
    end
  end
end
