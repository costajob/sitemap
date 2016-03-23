require 'sitemap/nodes'

module Sitemap
  class Mapper
    attr_reader :type

    def initialize(site:, entities: [], hreflang: true)
      @site = site
      @entities = entities
      @hreflang = hreflang
    end

    def urls
      filter_by_site.map! do |entity|
        URL::new(:loc => entity.loc).tap do |url|
          url.links = links(entity) if @hreflang
        end
      end
    end

    def type
      @entities.first.class.to_s.split("::").last.downcase
    end

    private

    def filter_by_site
      @entities.select { |entity| entity.site == @site }
    end

    def links(entity)
      entity.siblings(@entities).map! do |entity|
        Link::new(:site => entity.site, :loc => entity.loc)
      end
    end
  end
end
