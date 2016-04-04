require 'spec_helper'
require 'sitemap/config'

describe Sitemap::Config do
  it "must get hreflang file" do
    Sitemap::Config::hreflang.must_be_instance_of Hash
  end

  it "must get database file" do
    Sitemap::Config::database.must_be_instance_of Hash
  end

  it "must get connection parameters" do
    Sitemap::Config::connection_params.must_be_instance_of Hash
  end
end
