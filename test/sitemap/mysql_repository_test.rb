require 'test_helper'
require 'stubs'
require 'sitemap/mysql_repository'

describe Sitemap::MySQLRepository do
  let(:db) { Sitemap::MySQLRepository::DB }
  let(:repository) { Sitemap::MySQLRepository::new(:sites => %w[ae at it fr de bg]) }
  before { stub(repository).servers { OpenStruct::new(:all => Stubs::servers_data, :first => Stubs::servers_data.first)} }

  it "must collect categories" do
    stub(db).fetch { OpenStruct::new(:all => Stubs::categories_data) }
    assert repository.entities(Sitemap::Category).all? { |category| category.instance_of?(Sitemap::Category) }
  end

  it "must collect sorts" do
    stub(db).fetch { OpenStruct::new(:all => Stubs::sorts_data) }
    assert repository.entities(Sitemap::Sort).all? { |sort| sort.instance_of?(Sitemap::Sort) }
  end

  it "must collect styles" do
    stub(db).fetch { OpenStruct::new(:all => Stubs::styles_data) }
    assert repository.entities(Sitemap::Style).all? { |style| style.instance_of?(Sitemap::Style) }
  end

  it "must collect stores" do
    stub(db).fetch { OpenStruct::new(:all => Stubs::stores_data) }
    assert repository.entities(Sitemap::Store).all? { |store| store.instance_of?(Sitemap::Store) }
  end

  it "must collect homes" do
    assert repository.entities(Sitemap::Home).all? { |home| home.instance_of?(Sitemap::Home) }
  end

  it "must collect server paths" do
    repository.paths.must_equal %w[/vagrant/public/sitemap /home/vagrant/sitemap]
  end

  it "must fetch host name" do
    repository.host.must_equal "www.gucci.dev"
  end

  it "must execute SQL to fetch entities" do
    rs = OpenStruct::new(:all => [])
    %w[Category Sort Style Store].each do |entity|
      klass = Sitemap::const_get(entity)
      sql_method = repository.send(:sql_by_klass, klass)
      sql = repository.send(sql_method)
      mock(db).fetch(sql) { rs }
      repository.entities(klass).must_be_empty
    end
  end

  it "must return home entities without SQL" do
    dont_allow(repository).home_sql
    repository.entities(Sitemap::Home)
  end
end
