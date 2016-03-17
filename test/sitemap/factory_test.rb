require 'test_helper'
require 'sitemap/factory'

describe Sitemap::Factory do
  let(:categories) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>63}].map! { |attrs| Sitemap::Category::new(attrs) } }
  let(:sorts) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :sort => "pumps non US", :host=>"www.gucci.dev", :id=>63}].map! { |attrs| Sitemap::Sort::new(attrs) } }
  let(:styles) { [{:id=>"248516J87108367", :site=>"ae", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"at", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"it", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"fr", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"de", :host=>"www.gucci.dev"}, {:id=>"348516J87108367", :site=>"bg", :host=>"www.gucci.dev"}].map! { |attrs| Sitemap::Style::new(attrs) } }
  let(:stores) { [{:site=>"ae", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"at", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"de", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"fr", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"it", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"ch", :host=>"www.gucci.dev", :name=>"1-boulevard-de-locean-boulevard-de-la-corniche-ain-diab"}, {:site=>"bg", :host=>"www.gucci.dev", :name=>"1-dam"}].map! { |attrs| Sitemap::Store::new(attrs) } }
  let(:repository) { OpenStruct::new(:paths => [Dir::mktmpdir("sitemap1"), Dir::mktmpdir("sitemap2")], :host => "www.gucci.dev", :categories => categories, :sorts => sorts, :styles => styles, :stores => stores, :disconnect => true) }
  let(:factory) { Sitemap::Factory::new(:sites => " ae,at, it, fr ,de, bg", :repository => repository) }
  before do 
    def factory.fork; yield; end
    Sitemap::logger = Logger::new(nil)
  end

  it "must define default attributes" do
    factory.instance_variable_get(:@env).must_equal ENV.fetch("RAILS_ENV", "development")
    factory.instance_variable_get(:@sites).must_equal %w[ae at it fr de bg]
    factory.instance_variable_get(:@repository).must_be_instance_of repository.class
  end

  it "must create sitemaps and index" do
    factory.exec
    assert factory.files.any? { |f| f.match(/index\.xml/) }
    factory.files.each do |f|
      assert File.exist?(f)
    end
  end

  it "must propagate files" do
    factory.exec
    paths = factory.send(:paths)
    paths.each do |p|
      factory.files.map { |f| "#{p}/#{File::basename(f)}" }.each do |f|
        assert File.exist?(f)
      end
    end
  end
end
