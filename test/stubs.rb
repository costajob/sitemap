require 'sitemap/entities'

module Stubs
  extend self

  Repository = Struct::new(:paths, :host, :disconnect, :data) do
    def entities(klass); self.data.fetch(klass); end
  end

  def categories_data
    [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>63}]
  end

  def categories
    categories_data.map! { |attrs| Sitemap::Category::new(attrs) }
  end

  def sorts_data
    [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :sort => "pumps non US", :host=>"www.gucci.dev", :id=>63}]
  end

  def sorts
    sorts_data.map! { |attrs| Sitemap::Sort::new(attrs) }
  end

  def styles_data
    [{:id=>"248516J87108367", :site=>"ae", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"at", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"it", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"fr", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"de", :host=>"www.gucci.dev"}, {:id=>"348516J87108367", :site=>"bg", :host=>"www.gucci.dev"}]
  end

  def styles
    styles_data.map! { |attrs| Sitemap::Style::new(attrs) }
  end
  
  def stores_data
    [{:site=>"ae", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"at", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"de", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"fr", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"it", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"ch", :host=>"www.gucci.dev", :name=>"1-boulevard-de-locean-boulevard-de-la-corniche-ain-diab"}, {:site=>"bg", :host=>"www.gucci.dev", :name=>"1-dam"}]
  end

  def stores
    stores_data.map! { |attrs| Sitemap::Store::new(attrs) }
  end

  def homes_data
    %w[ae at it fr de bg].map! { |site| { :host => "www.gucci.dev", :site => site } }
  end
  
  def homes
    homes_data.map! { |attrs| Sitemap::Home::new(attrs) }
  end

  def servers_data
    [{:name=>"www.gucci.dev", :path=>"/vagrant/public", :id=>3}, {:name=>"www.gucci.dev", :path=>"/home/vagrant", :id=>3}]
  end
  
  def data_by_klass
    { Sitemap::Category => categories, Sitemap::Sort => sorts, Sitemap::Style => styles, Sitemap::Store => stores, Sitemap::Home => homes }
  end

  def repository
    Repository::new([Dir::mktmpdir("sitemap1"), Dir::mktmpdir("sitemap2")], "www.gucci.dev", true, data_by_klass)
  end
end

