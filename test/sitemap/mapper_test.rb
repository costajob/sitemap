require 'test_helper'
require 'sitemap/mapper'

describe Sitemap::Mapper do
  let(:categories) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>63}].map! { |attrs| Sitemap::Category::new(attrs) } }
  let(:sorts) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :sort => "pumps non US", :host=>"www.gucci.dev", :id=>63}].map! { |attrs| Sitemap::Sort::new(attrs) } }
  let(:styles) { [{:id=>"248516J87108367", :site=>"ae", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"at", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"it", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"fr", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"de", :host=>"www.gucci.dev"}, {:id=>"348516J87108367", :site=>"bg", :host=>"www.gucci.dev"}].map! { |attrs| Sitemap::Style::new(attrs) } }
  let(:stores) { [{:site=>"ae", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"at", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"de", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"fr", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"it", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"ch", :host=>"www.gucci.dev", :name=>"1-boulevard-de-locean-boulevard-de-la-corniche-ain-diab"}, {:site=>"bg", :host=>"www.gucci.dev", :name=>"1-dam"}].map! { |attrs| Sitemap::Store::new(attrs) } }
  let(:site) { "it" }
  let(:sites) { %w[it fr uk] }
  let(:mapper) { Sitemap::Mapper::new(:site => site, :categories => categories, :sorts => sorts, :styles => styles, :stores => stores) }
  let(:host) { "www.gucci.dev" }

  %w[categories sorts styles stores].each do |msg|
    it "must transform #{msg} to urls" do
      mapper.send("#{msg}_urls").each do |url|
        url.must_be_instance_of Sitemap::URL
        assert url.links.all? { |link| link.instance_of?(Sitemap::Link) }
      end
    end

    it "must select specified site only" do
      mapper.send("#{msg}_urls").each do |url|
        url.loc.must_match(/\/#{site}\//)
      end
    end

    it "must collect links from #{msg} siblings" do
      mapper.send("#{msg}_urls").each do |url|
        links = url.links
        link = links.shift
        link.loc.must_match(/\/#{site}\//)
        links.each do |link|
          link.loc.wont_match(/\/#{site}\//)
        end
      end
    end
  end

  it "must collect homes urls" do
    Sitemap::Mapper::homes_urls(host, sites).each do |url|
      url.must_be_instance_of Sitemap::URL
      assert url.links.all? { |link| link.instance_of?(Sitemap::Link) }
    end
  end

  it "must collect links from homes siblings" do
    Sitemap::Mapper::homes_urls(host, sites).each_with_index do |url,i|
      site = sites[i]
      links = url.links
      link = links.shift
      link.loc.must_match(/\/#{site}\//)
      links.each do |link|
        link.loc.wont_match(/\/#{site}\//)
      end
    end
  end
end
