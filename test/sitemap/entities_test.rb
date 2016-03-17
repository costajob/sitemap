require 'test_helper'
require 'sitemap/entities'

describe Sitemap::Category do
  let(:categories_data) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :host=>"www.gucci.dev", :id=>63}] }
  let(:category) { Sitemap::Category::new(categories_data.first) }
  let(:categories) { categories_data.map { |attrs| Sitemap::Category::new(attrs) } }

  it "must return loc value" do
    category.loc.must_equal "http://www.gucci.dev/ae/category/f/women_s_shoes"
  end

  it "must return siblings" do
    siblings = category.siblings(categories)
    siblings.wont_be_empty
    siblings.first.must_equal categories.first
    siblings.wont_include categories.last
  end
end

describe Sitemap::Sort do
  let(:sorts_data) { [{:site=>"ae", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"at", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"it", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"fr", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"de", :gender=>"F", :name=>"women's shoes", :sort => "sneakers non US", :host=>"www.gucci.dev", :id=>62}, {:site=>"bg", :gender=>"F", :name=>"women's shoes", :sort => "pumps non US", :host=>"www.gucci.dev", :id=>63}] }
  let(:sort) { Sitemap::Sort::new(sorts_data.first) }
  let(:sorts) { sorts_data.map { |attrs| Sitemap::Sort::new(attrs) } }

  it "must return loc value" do
    sort.loc.must_equal "http://www.gucci.dev/ae/category/f/women_s_shoes/sneakers_non_us"
  end

  it "must return siblings" do
    siblings = sort.siblings(sorts)
    siblings.wont_be_empty
    siblings.first.must_equal sorts.first
    siblings.wont_include sorts.last
  end
end

describe Sitemap::Style do
  let(:styles_data) { [{:id=>"248516J87108367", :site=>"ae", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"at", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"it", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"fr", :host=>"www.gucci.dev"}, {:id=>"248516J87108367", :site=>"de", :host=>"www.gucci.dev"}, {:id=>"348516J87108367", :site=>"bg", :host=>"www.gucci.dev"}] }
  let(:style) { Sitemap::Style::new(styles_data.first) }
  let(:styles) { styles_data.map { |attrs| Sitemap::Style::new(attrs) } }

  it "must return loc value" do
    style.loc.must_equal "http://www.gucci.dev/ae/style/248516J87108367"
  end

  it "must return siblings" do
    siblings = style.siblings(styles)
    siblings.wont_be_empty
    siblings.first.must_equal styles.first
    siblings.wont_include styles.last
  end
end

describe Sitemap::Store do
  let(:stores_data) { [{:site=>"ae", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"at", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"de", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"fr", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"it", :host=>"www.gucci.dev", :name=>"1-dam"}, {:site=>"ch", :host=>"www.gucci.dev", :name=>"1-boulevard-de-locean-boulevard-de-la-corniche-ain-diab"}, {:site=>"bg", :host=>"www.gucci.dev", :name=>"1-dam"}] }
  let(:store) { Sitemap::Store::new(stores_data.first) }
  let(:stores) { stores_data.map { |attrs| Sitemap::Store::new(attrs) } }

  it "must return loc value" do
    store.loc.must_equal "http://www.gucci.dev/ae/stores/1-dam"
  end

  it "must return siblings" do
    siblings = store.siblings(stores)
    siblings.wont_be_empty
    siblings.first.must_equal stores.first
    siblings.wont_include stores[-2]
  end
end

describe Sitemap::Home do
  let(:home) { Sitemap::Home::new(:host => "www.gucci.dev", :site => "it") }

  it "must return loc value" do
    home.loc.must_equal "http://www.gucci.dev/it/home"
  end

  it "must return siblings" do
    siblings = home.siblings(%w[it fr at de])
    siblings.wont_be_empty
    siblings.first.must_equal home
  end
end
