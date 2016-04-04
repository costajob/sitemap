require 'spec_helper'
require 'stubs'
require 'sitemap/factory'

describe Sitemap::Factory do
  let(:factory) { Sitemap::Factory::new(:sites => " ae,at, it, fr ,de, bg", :repository => Stubs::repository) }
  before { Sitemap::logger = Logger::new(nil) }

  it "must define default attributes" do
    factory.instance_variable_get(:@env).must_equal ENV.fetch("RAILS_ENV", "development")
    factory.instance_variable_get(:@sites).must_equal %w[ae at it fr de bg]
    factory.instance_variable_get(:@repository).must_be_instance_of Stubs::Repository
  end

  it "must call the no fork sitemaps" do
    mock(factory).sitemaps_no_fork
    factory.exec
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
