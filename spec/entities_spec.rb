require 'spec_helper'
require 'stubs'

describe Sitemap::Entity do
  it "must collect sub classes" do
    Sitemap::Entity::children.wont_be_empty
  end
end

describe Sitemap::Category do
  let(:category) { Sitemap::Category::new(Stubs::categories_data.first) }

  it "must return loc value" do
    category.loc.must_equal "http://www.gucci.dev/ae/category/f/women_s_shoes"
  end

  it "must return siblings" do
    siblings = category.siblings(Stubs::categories)
    siblings.wont_be_empty
    siblings.first.must_equal Stubs::categories.first
    siblings.wont_include Stubs::categories.last
  end
end

describe Sitemap::Sort do
  let(:sort) { Sitemap::Sort::new(Stubs::sorts_data.first) }

  it "must return loc value" do
    sort.loc.must_equal "http://www.gucci.dev/ae/category/f/women_s_shoes/sneakers_non_us"
  end

  it "must return siblings" do
    siblings = sort.siblings(Stubs::sorts)
    siblings.wont_be_empty
    siblings.first.must_equal Stubs::sorts.first
    siblings.wont_include Stubs::sorts.last
  end
end

describe Sitemap::Style do
  let(:style) { Sitemap::Style::new(Stubs::styles_data.first) }

  it "must return loc value" do
    style.loc.must_equal "http://www.gucci.dev/ae/style/248516J87108367"
  end

  it "must return siblings" do
    siblings = style.siblings(Stubs::styles)
    siblings.wont_be_empty
    siblings.first.must_equal Stubs::styles.first
    siblings.wont_include Stubs::styles.last
  end
end

describe Sitemap::Store do
  let(:store) { Sitemap::Store::new(Stubs::stores_data.first) }

  it "must return loc value" do
    store.loc.must_equal "http://www.gucci.dev/ae/stores/1-dam"
  end

  it "must return siblings" do
    siblings = store.siblings(Stubs::stores)
    siblings.wont_be_empty
    siblings.first.must_equal Stubs::stores.first
    siblings.wont_include Stubs::stores[-2]
  end
end

describe Sitemap::Home do
  let(:home) { Sitemap::Home::new(Stubs::homes_data.first) }

  it "must return loc value" do
    home.loc.must_equal "http://www.gucci.dev/ae/home"
  end

  it "must return siblings" do
    siblings = home.siblings(Stubs::homes)
    siblings.wont_be_empty
    siblings.first.must_equal Stubs::homes.first
  end
end
