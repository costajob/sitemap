require 'sitemap/factory'

namespace :sitemap do
  desc "generate sitemap for specified regions and environment: rake sitemap:factory env=production sites=it,fr,de"
  task :factory do
    Sitemap::Factory::new(:env => ENV["env"], :sites => ENV["sites"]).exec
  end
end
