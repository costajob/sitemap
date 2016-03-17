require 'test_helper'
require 'sitemap/repository'

describe Sitemap::Repository do
  let(:db) { Sitemap::Repository::DB }
  let(:repository) { Sitemap::Repository::new(:sites => %w[ae at it fr de bg]) }
  let(:categories) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>63}] }
  let(:sorts) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :sort => "pumps non US", :host=>"www.gucci.dev", :id=>63}] }
  let(:styles) { [{:id=>"248516J87108367", :site=>"ae", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"at", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"it", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"fr", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"de", :host=>"www.gucci.dev"}, {:id=>"348516J87108367", :site=>"bg", :host=>"www.gucci.dev"}] }
  let(:stores) { [{:site=>"ae", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"at", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"de", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"fr", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"it", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"ch", :host=>"www.gucci.dev", :name=>"1-boulevard-de-locean-boulevard-de-la-corniche-ain-diab"}, {:site=>"bg", :host=>"www.gucci.dev", :name=>"1-dam"}] }
  let(:servers) { [{:name=>"www.gucci.dev", :path=>"/vagrant/public", :id=>3}, {:name=>"www.gucci.dev", :path=>"/home/vagrant", :id=>3}] }
  before { stub(repository).servers { OpenStruct::new(:all => servers, :first => servers.first)} }

  it "must get config file" do
    Sitemap::Repository::config["development"].must_be_instance_of Hash
  end

  it "must collect categories" do
    stub(db).fetch { OpenStruct::new(:all => categories) }
    assert repository.categories.all? { |category| category.instance_of?(Sitemap::Category) }
  end

  it "must collect sorts" do
    stub(db).fetch { OpenStruct::new(:all => sorts) }
    assert repository.sorts.all? { |sort| sort.instance_of?(Sitemap::Sort) }
  end

  it "must collect styles" do
    stub(db).fetch { OpenStruct::new(:all => styles) }
    assert repository.styles.all? { |style| style.instance_of?(Sitemap::Style) }
  end

  it "must collect stores" do
    stub(db).fetch { OpenStruct::new(:all => stores) }
    assert repository.stores.all? { |store| store.instance_of?(Sitemap::Store) }
  end

  it "must collect server paths" do
    repository.paths.must_equal %w[/vagrant/public/sitemap /home/vagrant/sitemap]
  end

  it "must fetch host name" do
    repository.host.must_equal "www.gucci.dev"
  end

  it "must execute SQL to fetch entities" do
    rs = OpenStruct::new(:all => [])
    %w[categories sorts styles stores].each do |msg|
      mock(db).fetch(repository.send(:"#{msg}_sql")) { rs }
      repository.send(msg).must_be_empty
    end
  end
end
