require 'sitemap/factory'
require 'sitemap/mysql_repository'

namespace :sitemap do
  desc "generate sitemap for specified regions and environment: rake sitemap:factory env=production sites=it,fr,de hreflang=Y"
  task :factory do
    sites = ENV["sites"].to_s.split(",").map!(&:strip)
    repository = Sitemap::MySQLRepository::new(:env => ENV["env"], :sites => sites)
    Sitemap::Factory::new(:env => ENV["env"], 
                          :sites => ENV["sites"], 
                          :hreflang => ENV["hreflang"],
                          :repository => repository).exec
  end

  desc "remove generated sitemaps: rake sitemap:clean env=production"
  task :clean do
    Sitemap::MySQLRepository::new(:env => ENV["env"]) .paths.each do |p|
      FileUtils::rm_r Dir["#{p}/*"]
    end
  end
end
