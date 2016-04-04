require 'builder'
require 'spec_helper'
require 'sitemap/nodes'

describe Sitemap do
  let(:doc) { Builder::XmlMarkup.new(:target => "") }

  describe Sitemap::Link do
    let(:link) { Sitemap::Link::new(:site =>"it", :loc => "http://www.gucci.com/it/f/belts") }

    it "must return the lang attribute" do
      link.lang.must_equal "it-it"
    end

    it "must render the XML snippet" do
      link.render(doc).must_match(/^<xhtml:link/)
    end

    describe "noent language" do
      let(:noent) { Sitemap::Link::new(:site => "xx", :loc => "xx") }

      it "must recognize noent language" do
        refute noent.lang
      end

      it "wont render XML for noent language" do
        refute noent.render(doc)
      end
    end
  end

  describe Sitemap::URL do
    let(:url) { Sitemap::URL::new(:loc => "http://www.gucci.com/it/f/belts") }

    it "must render the XML snippet" do
      url.render(doc).must_equal %Q{<url><loc>http://www.gucci.com/it/f/belts</loc><lastmod>#{Date.today.strftime}</lastmod><changefreq>daily</changefreq></url>}
    end
  end

  describe Sitemap::Index do
    let(:index) { Sitemap::Index::new(:loc => "http://www.gucci.com/sitemap/it_sitemap.xml.gz") }

    it "must render the XML snippet" do
      index.render(doc).must_equal %Q{<sitemap><loc>http://www.gucci.com/sitemap/it_sitemap.xml.gz</loc><lastmod>#{Date.today.strftime}</lastmod></sitemap>}
    end
  end
end
