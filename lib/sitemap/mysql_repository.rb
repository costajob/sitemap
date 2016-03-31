require 'sequel'
require 'sitemap/config'
require 'sitemap/repository'

module Sitemap
  class MySQLRepository < Repository
    DB = Sequel.connect(Config::connection_params)

    def initialize(options = {})
      @env = options.fetch(:env) { Config::DB_ENV }
      @sites = options.fetch(:sites) { [] }
    end

    def entities(klass)
      return home_entities(klass) if klass == Sitemap::Home
      sql = send(sql_by_klass(klass))
      DB.fetch(sql).all.map! { |attrs| klass::new(attrs)}
    end

    def paths
      @paths ||= servers.all.map { |server| "#{server[:path]}/#{Config::BASE_FOLDER}" }
    end

    def host
      @host ||= "#{servers.first[:name]}"
    end

    def disconnect
      DB.disconnect
    end

    private

    def home_entities(klass)
      @sites.map { |site| klass::new(:host => host, :site => site) }
    end

    def sql_by_klass(klass)
      :"#{klass.to_s.split('::').last.downcase}_sql"
    end

    def category_sql
      %Q{SELECT ct.`id`, se.`server_name` AS host, si.`abbreviation` AS site, ge.`code` AS gender, ct.`abbreviation` AS name FROM `current_category_genders` ccg, `categories` ct, `sites` si, `servers` se, `genders` ge WHERE ccg.`category_id` = ct.`id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND ccg.`gender_id` = ge.`id` AND se.`id` = #{server_id} AND si.`abbreviation` IN(#{sites_condition}) ORDER BY si.`id`;}
    end

    def sort_sql
      %Q{SELECT sorts.`id`, se.`server_name` AS host, si.`abbreviation` AS site, ge.`code` AS gender, ct.`abbreviation` AS name, sorts.`abbreviation` AS sort FROM `current_category_genders` ccg, `categories` ct, `categories` sorts, `displays` di, `displayed_category_entries` dce, `sites` si, `servers` se, `genders` ge WHERE ccg.`category_id` = di.`category_id` AND di.`id` = dce.`owner_id` AND dce.`owner_type` = "Display" AND sorts.`id` = dce.`category_id` AND ct.`id` = ccg.`category_id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND ccg.`gender_id` = ge.`id` AND se.`id` = #{server_id} AND si.`abbreviation` IN(#{sites_condition}) GROUP BY sorts.`id`, si.`id`, ge.`id` ORDER BY si.`id`;}
    end

    def style_sql
      %Q{SELECT se.`server_name` AS host, si.`abbreviation` AS site, sw.`style_id` AS id FROM `current_category_genders` ccg, `current_style_wrappers` csw, `style_wrappers` sw, `sites` si, `servers` se WHERE ccg.`id` = csw.`current_category_gender_id` AND csw.`style_wrapper_id` = sw.`id` AND ccg.`site_id` = si.`id` AND ccg.`server_id` = se.`id` AND se.id = #{server_id} AND si.abbreviation IN(#{sites_condition}) GROUP BY si.`id`, sw.`id` ORDER BY si.`id`;}
    end

    def server_sql
      %Q{SELECT se.`id`, se.`server_name` AS name, pse.`sitemap` AS path FROM `servers` se, `physical_servers` pse WHERE se.`id` = pse.`server_id` AND se.`rails_environment` = "#{@env}";}
    end

    def store_sql
      %Q{SELECT se.server_name AS host, si.`abbreviation` AS site, st.`slug` AS name FROM `servers` se, `sites` si, `storefinder_stores` st WHERE st.`publish_state` = "published" AND se.`id` = #{server_id} AND st.`slug` != "" AND si.`abbreviation` IN(#{sites_condition}) GROUP BY se.`server_name`, si.`abbreviation`, st.`slug`;}
    end

    def servers
      @servers ||= DB.fetch(server_sql)
    end

    def server_id
      servers.first[:id] 
    end

    def sites_condition
      @sites.map { |abbr| %Q{"#{abbr}"} }.join(",")
    end
  end
end
