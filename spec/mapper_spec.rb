require 'spec_helper'
require 'stubs'
require 'sitemap/mapper'

describe Sitemap::Mapper do
  let(:site) { "it" }

  %w[categories sorts styles stores homes].each do |msg|
    entities = Stubs::send(msg)

    it "must get #{msg} urls and links" do
      mapper = Sitemap::Mapper::new(:site => site, :entities => entities)
      mapper.urls.each do |url|
        url.must_be_instance_of Sitemap::URL
        assert url.links.all? { |link| link.instance_of?(Sitemap::Link) }
      end
    end

    it "must get just #{msg} urls" do
      mapper = Sitemap::Mapper::new(:site => site, :entities => entities, :hreflang => false)
      mapper.urls.each do |url|
        url.must_be_instance_of Sitemap::URL
        url.links.must_be_empty
      end
    end

    it "must select #{msg} specified site only" do
      mapper = Sitemap::Mapper::new(:site => site, :entities => entities)
      mapper.urls.each do |url|
        url.loc.must_match(/\/#{site}\//)
      end
    end

    it "must collect #{msg} links from siblings" do
      mapper = Sitemap::Mapper::new(:site => site, :entities => entities)
      mapper.urls.each do |url|
        links = url.links
        link = links.shift
        link.loc.must_match(/\/#{site}\//)
        links.each do |link|
          link.loc.wont_match(/\/#{site}\//)
        end
      end
    end
  end

  it "must fetch type basing on entities class" do
    mapper = Sitemap::Mapper::new(:site => site, :entities => Stubs::sorts)
    mapper.type.must_equal "sort"
  end
end
