require 'sitemap/factory'

namespace :sitemap do
  desc "generate sitemap for specified regions and environment: rake sitemap:factory env=production sites=it,fr,de hreflang=Y"
  task :factory do
    Sitemap::Factory::new(env: ENV["env"], sites: ENV["sites"], hreflang: ENV["hreflang"]).exec
  end

  desc "remove generated sitemaps: rake sitemap:clean env=production"
  task :clean do
    Sitemap::Repository::new(env: ENV["env"]) .paths.each do |p|
      FileUtils::rm_r Dir["#{p}/*"]
    end
  end
end
