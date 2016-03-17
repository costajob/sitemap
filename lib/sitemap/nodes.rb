require 'date'

module Sitemap
  class Node
    TODAY = Date.today.strftime.freeze
    DAILY = "daily".freeze

    def initialize(options = {})
      @lastmod = options.fetch(:lastmod) { TODAY }
    end

    def render
      fail NotImplementedError
    end
  end

  class Link < Node
    attr_reader :site, :loc

    def initialize(options = {})
      @site = options.fetch(:site) { fail ArgumentError, "missing abbreviation" }
      @loc = options.fetch(:loc) { fail ArgumentError, "missing loc"}
    end

    def lang
      @lang ||= Sitemap::config[@site]
    end

    def render(doc)
      return unless lang
      doc.tag!("xhtml:link", :href => @loc, :hreflang => lang, :rel => :alternate)
    end
  end

  class URL < Node
    attr_reader :loc, :lastmod, :changefreq, :links

    def initialize(options = {})
      super
      @loc = options.fetch(:loc) { fail ArgumentError, "missing loc"} 
      @changefreq = options.fetch(:changefreq) { DAILY } 
      @links = options.fetch(:links) { [] }
    end

    def render(doc)
      doc.url do
        doc.loc(@loc)
        doc.lastmod(@lastmod)
        doc.changefreq(@changefreq)
        @links.each do |link|
          link.render(doc)
        end
      end
    end
  end

  class Index < Node
    attr_reader :loc, :lastmod

    def initialize(options = {})
      super
      @loc = options.fetch(:loc) { fail ArgumentError, "missing loc"} 
    end

    def render(doc)
      doc.sitemap do
        doc.loc(@loc)
        doc.lastmod(@lastmod)
      end
    end
  end
end
