require 'sequel'
require 'yaml'
require 'erb'
require 'sitemap/entities'

module Sitemap
  BASE_FOLDER = "sitemap"

  def self.config
    @config ||= YAML::load_file(File.expand_path("../../../config/sitemap.yml", __FILE__))
  end

  class Repository
    DB_ENV = ENV.fetch("RAILS_ENV") { "development" }

    class NoentConnectionError < ArgumentError; end
    class NoSitesError < ArgumentError; end

    def self.config
      @config ||= YAML.load(ERB.new(File.read(File.expand_path("../../../config/database.yml", __FILE__))).result)
    end

    def self.connection_details
      config.fetch(DB_ENV) { fail NoentConnectionError, "missing connection for #{@env}" }
    end

    DB = Sequel.connect(connection_details)

    def initialize(options = {})
      @env = options.fetch(:env) { DB_ENV }
      @sites = fetch_sites(options)
    end

    def categories
      @categories ||= DB.fetch(categories_sql).all.map! { |attrs| Category::new(attrs) }
    end

    def sorts
      @sorts ||= DB.fetch(sorts_sql).all.map! { |attrs| Sort::new(attrs) }
    end

    def styles
      @styles ||= DB.fetch(styles_sql).all.map! { |attrs| Style::new(attrs) }
    end

    def stores
      @stores ||= DB.fetch(stores_sql).all.map! { |attrs| Store::new(attrs) }
    end

    def paths
      @paths ||= servers.all.map { |server| "#{server[:path]}/#{BASE_FOLDER}" }
    end

    def host
      @host ||= "#{servers.first[:name]}"
    end

    def disconnect
      DB.disconnect
    end

    private

    def fetch_sites(options)
      sites = options.fetch(:sites) { [] }
      fail NoSitesError if sites.empty?
      sites
    end

    def categories_sql
      %Q{SELECT ct.`id`, se.`server_name` AS host, si.`abbreviation` AS site, ge.`code` AS gender, ct.`abbreviation` AS name FROM `current_category_genders` ccg, `categories` ct, `sites` si, `servers` se, `genders` ge WHERE ccg.`category_id` = ct.`id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND ccg.`gender_id` = ge.`id` AND se.`id` = #{server_id} AND si.`abbreviation` IN(#{sites_condition}) ORDER BY si.`id`;}
    end

    def sorts_sql
      %Q{SELECT sorts.`id`, se.`server_name` AS host, si.`abbreviation` AS site, ge.`code` AS gender, ct.`abbreviation` AS name, sorts.`abbreviation` AS sort FROM `current_category_genders` ccg, `categories` ct, `categories` sorts, `displays` di, `displayed_category_entries` dce, `sites` si, `servers` se, `genders` ge WHERE ccg.`category_id` = di.`category_id` AND di.`id` = dce.`owner_id` AND dce.`owner_type` = "Display" AND sorts.`id` = dce.`category_id` AND ct.`id` = ccg.`category_id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND ccg.`gender_id` = ge.`id` AND se.`id` = #{server_id} AND si.`abbreviation` IN(#{sites_condition}) GROUP BY sorts.`id`, si.`id`, ge.`id` ORDER BY si.`id`;}
    end

    def styles_sql
      %Q{SELECT se.`server_name` AS host, si.`abbreviation` AS site, sw.`style_id` AS id FROM `current_category_genders` ccg, `current_style_wrappers` csw, `style_wrappers` sw, `sites` si, `servers` se WHERE ccg.`id` = csw.`current_category_gender_id` AND csw.`style_wrapper_id` = sw.`id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND se.id = #{server_id} AND si.abbreviation IN(#{sites_condition}) GROUP BY si.`id`, sw.`id` ORDER BY si.`id`;}
    end

    def servers_sql
      %Q{SELECT se.`id`, se.`server_name` AS name, pse.`sitemap` AS path FROM `servers` se, `physical_servers` pse WHERE se.`id` = pse.`server_id` AND se.`rails_environment` = "#{@env}";}
    end

    def stores_sql
      %Q{SELECT se.server_name AS host, si.`abbreviation` AS site, st.`slug` AS name FROM `servers` se, `sites` si, `storefinder_stores` st WHERE st.`publish_state` = "published" AND se.`id` = #{server_id} AND st.`slug` != "" AND si.`abbreviation` IN(#{sites_condition}) GROUP BY se.`server_name`, si.`abbreviation`, st.`slug`;}
    end

    def servers
      @servers ||= DB.fetch(servers_sql)
    end

    def server_id
      servers.first[:id] 
    end

    def sites_condition
      @sites.map { |abbr| %Q{"#{abbr}"} }.join(",")
    end
  end
end
