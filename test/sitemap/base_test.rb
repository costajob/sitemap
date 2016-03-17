require 'test_helper'
require 'sitemap/base'

describe Sitemap::Base do
  let(:node1) { Struct::new(:val) { def render(doc); doc.url(self.val, :hreflang => "it-it"); end } }
  let(:node2) { Struct::new(:val) { def render(doc); doc.sitemap { doc.loc(self.val); doc.lastmod("2010-10-10") }; end } }
  let(:sitemap) { Sitemap::Base::new(:nodes => 3.times.map { |i| node1::new("http://www.gucci.com/#{i}") }) }
  let(:path) { "/vagrant/public/sitemap/#{sitemap.name}.gz" }

  it "must initialize the out attribute" do
    sitemap.instance_variable_get(:@out).must_equal ""
  end

  it "must initialize the name attribute" do
    sitemap.instance_variable_get(:@name).must_equal "sitemap.xml"
  end

  it "must call compress on Zlib and call block" do
    mock(Zlib::GzipWriter).open(path) { 2039 }
    assert sitemap.compress(path) > 0
  end

  it "must render the urlset XML document" do
    nodes = 5.times.map { |i| node1::new("http://www.gucci.com/#{i}") }
    sitemap = Sitemap::Base::new(:nodes => nodes, :indent => 0)
    sitemap.render.must_equal(%q{<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url hreflang="it-it">http://www.gucci.com/0</url><url hreflang="it-it">http://www.gucci.com/1</url><url hreflang="it-it">http://www.gucci.com/2</url><url hreflang="it-it">http://www.gucci.com/3</url><url hreflang="it-it">http://www.gucci.com/4</url></urlset>})
  end

  it "must render the index XML document" do
    nodes = 5.times.map { |i| node2::new("http://www.gucci.com/sitemap/#{i}.xml.gz") }
    sitemap = Sitemap::Base::new(:nodes => nodes, :parent => :sitemapindex, :indent => 0)
    sitemap.render.must_equal(%q{<?xml version="1.0" encoding="UTF-8"?><sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><sitemap><loc>http://www.gucci.com/sitemap/0.xml.gz</loc><lastmod>2010-10-10</lastmod></sitemap><sitemap><loc>http://www.gucci.com/sitemap/1.xml.gz</loc><lastmod>2010-10-10</lastmod></sitemap><sitemap><loc>http://www.gucci.com/sitemap/2.xml.gz</loc><lastmod>2010-10-10</lastmod></sitemap><sitemap><loc>http://www.gucci.com/sitemap/3.xml.gz</loc><lastmod>2010-10-10</lastmod></sitemap><sitemap><loc>http://www.gucci.com/sitemap/4.xml.gz</loc><lastmod>2010-10-10</lastmod></sitemap></sitemapindex>})
  end
end
